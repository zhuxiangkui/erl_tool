%%%-------------------------------------------------------------------
%%% @author zou <>
%%% @copyright (C) 2017, zou
%%% @doc
%%%
%%% @end
%%% Created : 25 Jul 2017 by zou <>
%%%-------------------------------------------------------------------
%% must run in ejabberd/msync debug
%% start transfer:
%% roster_rds_to_pika:start(SqlFileName, TransferUserNumberEverySecond).
%% roster_rds_to_pika:start("/data/apps/opt/ejabberd/rosterusers.sql", 1000).
%% stop transfer:
%% roster_rds_to_pika:stop().

-module(roster_rds_to_pika).

-behaviour(gen_server).

%% API
-export([start/2, start/3, stop/0, is_running/0, is_good_exit/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {
          fd,
          data=[],
          speed,
          shaper,
          read_size,
          max_offset,
          now_offset,
          transfer_cnt = 0,
          skip_cnt = 0
 }).
-define(TAB, rds2pika).
-define(DETS_FILE, "rds2pika.dat").
-define(BEGIN, "('").
-define(END, "'").
-define(INFO_MSG(Format, Args), spawn(fun()->error_logger:info_msg("~s:~p "++Format++"~n",[?MODULE, ?LINE]++Args) end)).
-define(ERROR_MSG(Format, Args), error_logger:error_msg("~s:~p "++Format++"~n",[?MODULE, ?LINE]++Args)).

%%%===================================================================
%%% API
%%%===================================================================
start(FileName, Speed) ->
    start(FileName, Speed, true).
start(FileName, Speed, IsContinue) ->
    stop(),
    gen_server:start({local, ?SERVER}, ?MODULE, [FileName, Speed, IsContinue], []).

stop() ->
    application:unset_env(message_store, {?MODULE, run_result}),
    case whereis(?MODULE) of
        Pid when is_pid(Pid) ->
            Ref = erlang:monitor(process, Pid),
            exit(Pid, kill),
            receive
                {'DOWN', Ref, process, _Pid, _Reason} -> 
                    ok
            end;
        _ ->
            skip
    end.

is_running() ->
    case whereis(?MODULE) of
        Pid when is_pid(Pid) ->
            true;
        _ ->
            false
    end.

is_good_exit() ->
    case application:get_env(message_store, {?MODULE, run_result}) of
        {ok, {error, eof}} ->
            true;
        _ ->
            false
    end.

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([FileName, Speed, IsContinue]) ->
    case IsContinue of
        false ->
            file:delete(?DETS_FILE);
        true ->
            ok
    end,
    dets:open_file(?TAB,[{file, ?DETS_FILE},{type,set},{keypos,1}]),
    {ok, Fd} = file:open(FileName, [read]),
    self() ! loop,
    {ok,MaxOffset} = file:position(Fd,{eof,0}),
    ReadSize = 64 * 1024,
    NowOffset = max(read_now_offset() - ReadSize * 2,0),
    {ok, _} = file:position(Fd, {bof, NowOffset}),
    {ok, #state{fd=Fd,
                speed=Speed,
                shaper=shaper:new2(Speed),
                max_offset = MaxOffset,
                now_offset = NowOffset,
                read_size = ReadSize
               }}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(loop, State) ->
    case catch handle_loop(State) of
        {ok, NewState, Add} ->
            {NewShaper, Sleep} = shaper:update(NewState#state.shaper, Add),
            if
                Sleep > 0 ->
                    erlang:send_after(Sleep, self(), loop);
                true ->
                    self() ! loop
            end,
            {noreply, NewState#state{shaper=NewShaper}};
        {retry, Reason} ->
            ?ERROR_MSG("Retry with reason:~p", [Reason]),
            erlang:send_after(1000, self(), loop),
            {noreply, State};
        Other ->
            ?INFO_MSG("Stop with:state=~p, skip_cnt=~p, transfer_cnt=~p, res=~p",
                      [State, State#state.skip_cnt, State#state.transfer_cnt, Other]),
            application:set_env(message_store, {?MODULE, run_result}, Other),
            application:set_env(message_store, {?MODULE, run_state}, [R||R<-tuple_to_list(State), is_integer(R) orelse is_list(R)]),
            {stop, normal, State}
    end;
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, State) ->
    dets:close(?TAB),
    file:close(State#state.fd),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
handle_loop(State) ->
    case read_user(State) of
        {ok, User, State1} ->
            case is_old_user(User) of
                true ->
                    %?INFO_MSG("SkipUser:~p",[User]),
                    {ok, State1, 0};
                false ->
                    %?INFO_MSG("CheckUser:~p",[User]),
                    {ok, State2} = transfer_roster(State1, User),
                    set_old_user(User),
                    {ok, State2, 1}
            end;
        {error, Reason} ->
            {error, Reason}
    end.

transfer_roster(#state{now_offset = NowOffset, 
                       max_offset=MaxOffset,
                       skip_cnt = SkipCnt,
                       transfer_cnt = TransferCnt}=State,User) ->
    Server = <<"easemob.com">>,
    RdsRosters = 
        case easemob_roster_cache:read_rosters(User, Server) of
            not_found ->
                easemob_roster:get_roster(User, Server, odbc);
            Rs -> Rs
        end,
    PikaRosters =
        easemob_roster:get_roster(User, Server, pika),
    case is_list(RdsRosters) andalso is_list(PikaRosters) of
        true ->
            case is_need_transfer(RdsRosters, PikaRosters) of
                false ->
                    ?INFO_MSG("transfer skip:~p, progress=~p/~p (~.2f%), skip_cnt=~p",
                              [User, NowOffset, MaxOffset, 100 * NowOffset / MaxOffset, SkipCnt+1]),
                    {ok, State#state{skip_cnt = SkipCnt + 1}};
                true ->
                    TransferRes = easemob_roster_pika:write_rosters(User, RdsRosters),
                    ?INFO_MSG("transfer roster for user:~p, progress=~p/~p (~.2f%), transfer_cnt=~p, res=~p,",
                              [User, NowOffset, MaxOffset, 100 * NowOffset / MaxOffset, TransferCnt+1, TransferRes]),
                    case TransferRes  of
                        ok ->
                            {ok, State#state{transfer_cnt = TransferCnt+1}};
                        {error, Reason} ->
                            throw({retry, {transfer_roster_fail, User, Reason}})
                    end
            end;
        false ->
            throw({retry, {read_roster_fail, User, PikaRosters, RdsRosters}})
    end.

is_need_transfer(RdsRosters, PikaRosters) when length(RdsRosters) > length(PikaRosters) ->
    true;
is_need_transfer(_,_) ->
    false.

is_old_user(User) ->
    case dets:lookup(?TAB, User) of
        [_] ->
            true;
        [] ->
            false;
        {error, Reason} ->
            throw({retry, {dets_fail, User, Reason}})
    end.

set_old_user(User) ->
    dets:insert(?TAB, {User, 1}).

read_user(#state{data=Data}=State) ->
    case string:str(Data, ?BEGIN) of
        0 ->
            read_data(State#state{data=[]});
        Idx ->
            Data1 = string:substr(Data, Idx+2),
            case string:str(Data1, ?END) of
                0 ->
                    read_data(State#state{data=?BEGIN++Data1});
                Idx2 ->
                    User = string:substr(Data1, 1, Idx2-1),
                    {ok, list_to_binary(User), State#state{data=Data1}}
            end
    end.

read_data(#state{fd=Fd, data=OldData, read_size = ReadSize, now_offset = NowOffset, max_offset=MaxOffset}=State) ->
    case file:read(Fd, ReadSize) of
        {ok, Data} ->
            NowOffset1 = NowOffset + length(Data),
            update_now_offset(NowOffset1),
            ?INFO_MSG("read progress=~p/~p (~.2f%)",[NowOffset1, MaxOffset, 100 * NowOffset1 / MaxOffset]),
            read_user(State#state{data=OldData ++ Data, now_offset = NowOffset1});
        eof ->
            {error, eof};
        {error, Reason} ->
            {error, Reason}
    end.

update_now_offset(NowOffset) ->
    dets:insert(?TAB, {now_offset, NowOffset}).
read_now_offset() ->
    case dets:lookup(?TAB, now_offset) of
        [{_, NowOffset}] ->
            NowOffset;
        [] ->
            0
    end.
