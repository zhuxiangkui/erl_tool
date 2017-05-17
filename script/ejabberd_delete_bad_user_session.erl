%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016
%%% @doc
%%%
%%% @end
%%% Created :
%%%-------------------------------------------------------------------
-module(ejabberd_delete_bad_user_session).

%% delete bad user session, must run in ejabberdctl debug
%% ejabberd_delete_bad_user_session:start("10.46.175.163", 18087, codis).
%% ejabberd_delete_bad_user_session:stop().

%% API
-export([
         start/3,
         stop/0,
         scan/6,
         scan_worker/5,
         do_scan/6,
         do_handle_key/3,
         start_from_codis/2,
         stop_all/1
]).

-define(SCAN_COUNT, 1000).
-define(REDIS_TIMEOUT, 60000).
-include("logger.hrl").
-record(session, {usr, sid, us, priority, info}).
%%%===================================================================
%%% API
%%%===================================================================

start(Host, Port, CodisOrRedis) ->
    scan(Host, Port, CodisOrRedis, delete_bad_user_session, [true], 1000000000).

stop() ->
    stop_all(delete_bad_user_session).
    
scan(Host, Port, CodisOrRedis, RunMode, RunArgs, MaxScan) ->
    stop_all(RunMode),
    ServerList = server_list(Host, Port, CodisOrRedis),
    Pids = [scan_worker(RedisHost, RedisPort, RunMode, RunArgs, MaxScan)
            ||{RedisHost, RedisPort}<-ServerList],
    application:set_env(message_store, {codis_scan_pid_list, RunMode}, Pids),
    {ok,Pids}.

server_list(Host, Port, codis) ->
    {ok, ServerList} = start_from_codis(Host, Port),
    ServerList;
server_list(Host, Port, redis) ->
    [{Host,Port}].

stop_all(RunMode) ->
    [exit(OldPid, kill)||OldPid<-application:get_env(message_store, {codis_scan_pid_list, RunMode}, [])],
    ok.

scan_worker(RedisHost, RedisPort, RunMode, RunArgs, MaxScan) ->
    proc_lib:spawn(?MODULE, do_scan, [RedisHost, RedisPort, RunMode, RunArgs, 0, MaxScan]).

do_scan(RedisHost, RedisPort, RunMode, RunArgs, Cursor, MaxScan) when MaxScan > 0 ->
    ?INFO_MSG("do scan:server=~p,cursor=~p",[{RedisHost,RedisPort},Cursor]),
    case scan_key_list(RedisHost, RedisPort, Cursor) of
        {ok, finish, List} ->
            do_handle(List, RunMode, RunArgs),
            ?INFO_MSG("Scan finish with finish:s=~p", [ {RedisHost,RedisPort}]),
            ok;
        {ok, Next, List}->
            do_handle(List, RunMode, RunArgs),
            ?MODULE:do_scan(RedisHost, RedisPort, RunMode, RunArgs, Next, MaxScan-1);
        {error, Error} ->
            ?INFO_MSG("Scan finish with Error:~p,s=~p", [Error, {RedisHost,RedisPort}]),
            {error, Error}
    end;
do_scan(RedisHost, RedisPort, _RunMode, _RunArgs, _Cursor, _MaxScan) ->
    ?INFO_MSG("Scan finish with :~p,s=~p", [max_scan, {RedisHost,RedisPort}]),
    ok.


do_handle(List, RunMode, RunArgs) ->
    ?INFO_MSG("do_handle keys=~p",[List]),
    [try
         ?MODULE:do_handle_key(Key, RunMode, RunArgs)
     catch
         C:E ->
             ?ERROR_MSG("handle_key_error:key=~p, error=~p",[Key, {C,E,erlang:get_stacktrace()}])
     end
     ||Key<-List],
    ok.

do_handle_key(Key, remove_cid_from_user_has_muc_mid, [AppKeys, IsDel]) ->
    case binary_to_list(Key) of
        "index:unread:" ++ Rest ->
            case string:tokens(Rest, ":") of
                [User, CId] ->
                    case string:tokens(User, "/@_") of
                        [AppKey, _ID, "easemob.com"|_] ->
                            case lists:member(AppKey, AppKeys) of
                                true ->
                                    case string:tokens(CId, "@/") of
                                        [_User,"easemob.com"|_] ->
                                            %?INFO_MSG("do_handle_key:key=~p",[Key]),
                                            remove_cid_from_user_has_muc_mid(Key, list_to_binary(User), list_to_binary(CId), IsDel);
                                        _ ->
                                            skip
                                    end;
                                false ->
                                    skip
                            end;
                        _ ->
                            skip
                    end;
                _ ->
                    skip
            end;
        _ ->
            skip
    end;
do_handle_key(Key, delete_bad_user_session, [IsDel]) ->
    case binary_to_list(Key) of
        "im:sr:" ++ Rest when length(Rest) > 0 ->
            User = list_to_binary(Rest),
            case ejabberd_sm:get_sessions(<<"easemob.com">>,[User]) of
                [{User, PrioResSessionList}] ->
                    lists:foreach(fun({_P,R,S}) ->
                                          check_session(User, R, S, IsDel)
                                  end, PrioResSessionList);
                _ ->
                    skip
            end;
        _ ->
            skip
    end.


check_session(User, Resource, Session, IsDel) ->
     case  is_bad_session(Session) of
        true ->
            case IsDel of
                true ->
                    Key = <<"im:sr:",User/binary>>,
                    mod_session_redis:redis_q(client(), ["HDEL", Key, Resource]);
                _ ->
                    skip
            end,
            ok;
        false  ->
            skip
    end.

is_bad_session(#session{usr={User, Server, Resource}, sid={_,{msync_c2s, Node}}}=Session) ->
    JID = msync_msg:parse_jid(<<User/binary,"@",Server/binary, "/",Resource/binary>>),
    case rpc:call(Node, msync_c2s_lib, get_pb_jid_prop, [JID, socket]) of
        {error, not_found} ->
            ?INFO_MSG("found_bad_session_msync:User=~p,Resource=~p,Session=~p,reason=~p",[User, Resource, Session, not_found]),
            true;
        {badrpc, nodedown} ->
            ?INFO_MSG("found_bad_session_msync:User=~p,Resource=~p,Session=~p,reason=~p",[User, Resource, Session, node_down]),
            true;
        _Other ->
            %?INFO_MSG("found_good_session_msync:User=~p,Resource=~p,Session=~p,Other=~p",[User, Resource, Session,_Other]),
            false
    end;
is_bad_session(#session{usr={User, _Server, Resource},sid={_, Pid}}=Session) ->
    case  is_pid(Pid) andalso is_process_alive_allnode(Pid) == false of
        true ->
            ?INFO_MSG("found_bad_session_ejabberd:User=~p,Resource=~p,Session=~p,reason=~p",[User, Resource, Session, pid_not_alive]),
            true;
        _ ->
            false
    end;
is_bad_session(_) ->
    false.


client() ->
    mod_session_redis:client(<<"easemob.com">>).

is_process_alive_allnode(Pid) ->
    case catch rpc:call(node(Pid), erlang, is_process_alive, [Pid]) of
        true ->
            true;
        _ ->
            false
    end.

remove_cid_from_user_has_muc_mid(_Key, User, CId, IsDel) ->
    Mids = easemob_offline_index:read_message_index(User, CId, 0),
    F = fun(Mid) ->
                try
                    MsgBin = easemob_message_body:read_message(Mid),
                    %?INFO_MSG("Msg:mid=~p,BIN=~p",[Mid, MsgBin]),
                    Res =
                        case MsgBin of
                            <<"not_found">> ->
                                skip_not_found;
                            <<"<", _/binary >> ->
                                XmlEl = xml_stream:parse_element(MsgBin),
                                case xml:get_tag_attr(<<"to">>, XmlEl) of
                                    {value, To} ->
                                        {to, To, XmlEl};
                                    error ->
                                        error
                                end;
                            _ when is_binary(MsgBin) ->
                                Meta = msync_msg:decode_meta(MsgBin),
                                ToJID = msync_msg:get_meta_to(Meta),
                                To = msync_msg:pb_jid_to_binary(ToJID),
                                {to, To, Meta};
                            Other ->
                                Other
                        end,
                    case Res of
                        {to, To1, XmlOrMeta} ->
                            ToStr = binary_to_list(To1),
                            case string:tokens(ToStr, "@/") of
                                [GroupId, "conference.easemob.com"|_] ->
                                    ?INFO_MSG("Msg:To=~p,mid=~p,XmlOrMeta=~p",[To1, Mid, XmlOrMeta]),
                                    case IsDel of
                                        true ->
                                            DelRes = (catch easemob_offline_index:delete_message(User, CId, Mid)),
                                            ?INFO_MSG("remove muc msg:user=~p,Cid=~p,to=~p, DelRes=~p, GroupId=~p, msg=~p",
                                              [User, CId, To1, DelRes, GroupId, XmlOrMeta]),
                                            deleted;
                                        _ ->
                                            ?INFO_MSG("skip remove muc msg:user=~p,Cid=~p,to=~p, GroupId=~p, msg=~p",
                                              [User, CId, To1, GroupId, XmlOrMeta]),
                                            delete_skiped
                                    end;
                                _ ->
                                    skip
                            end;
                        _Other->
                            skip
                    end
                catch
                    C:E ->
                        ?ERROR_MSG("error check:error=~p",[{C,E,erlang:get_stacktrace()}]),
                        error
                end
        end,
    lists:foreach(F, Mids),
    ok.

scan_key_list(RedisHost, RedisPort, Cursor) ->
    try
        {ok, Pid} = eredis:start_link(RedisHost, RedisPort),
        Res =
            case eredis:q(Pid, ["scan", Cursor, "count", ?SCAN_COUNT], ?REDIS_TIMEOUT) of
                {ok, [Next, undefined]} ->  % not sure if this case will happen
                    {ok, Next, []};
                {ok, [<<"0">>, List]} ->
                    ?INFO_MSG("Server: ~p finish scanning~n", [{RedisHost,RedisPort}]),
                    {ok, finish, List};
                {ok, [Next, List]} ->
                    {ok, Next, List};
                Error ->
                    ?INFO_MSG("scan error:error=~p, args=~p~n", [Error, {RedisHost, RedisPort, Cursor}]),
                    {error, Error}
            end,
        eredis:stop(Pid),
        Res
    catch
        C:E ->
            ?INFO_MSG("scan error:error=~p, args=~p, s=~p~n",
                      [{C,E}, {RedisHost, RedisPort, Cursor}, erlang:get_stacktrace()]),
            {error, {C,E}}
    end.

start_from_codis(CodisHost, CodisPort) ->
    Json = read_codis_redis_config(CodisHost, CodisPort),
    ?INFO_MSG("Json: ~p~n", [Json]),
    ServerList = get_server_list(Json),
    ?INFO_MSG("ServerList: ~p~n", [ServerList]),
    {ok, ServerList}.

read_codis_redis_config(CodisHost, CodisPort) ->
    CmdStr = "curl -s " ++ CodisHost ++ ":" ++ integer_to_list(CodisPort) ++ "/api/server_groups",
    Result = list_to_binary(os:cmd(CmdStr)),
    {Start, _Len} = binary:match(Result, <<"[">>),
    binary:part(Result, Start, byte_size(Result) - Start).

get_server_list(Json) ->
    MapList = jsx:decode(Json, [return_maps]),
    lists:flatmap(fun(#{<<"servers">> := ServerMapList}) ->
        lists:filtermap(fun redis_server_filter/1, ServerMapList)
    end, MapList).

redis_server_filter(#{<<"type">> := <<"slave">>, <<"addr">> := Addr}) ->
    [RedisHost, RedisPort] = binary:split(Addr, <<":">>, [global]),
    {true, {binary_to_list(RedisHost), binary_to_integer(RedisPort)}};
redis_server_filter(_Master) ->
    false.
