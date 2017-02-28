
%% input: 
%%   Host :: codis host / redis host
%%   Port :: 
%%   RedisOrCodis :: codis / redis
%%   RunMode :: delete / dry_run
%%
%% op: clean expired resource
%%
%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' 
%%                                              common/clean_resource.erl sdb-ali-hangzhou-redis3 6379 redis delete
%%


echo(off),

[Host, Port, RedisOrCodis, RunMode] = Args,

%-define(SCAN_COUNT, 1000).
%-define(REDIS_TIMEOUT, 600000).
%-define(OVERTIME_DAYS, 10).
%-define(TTID_TIME_BEGIN, 1417564800).  %% seconds diff to 20141203 00:00:00 GMT
%-define(SEC_OF_ONE_DAY, 86400).

SCAN_COUNT = 1000,
REDIS_TIMEOUT = 600000,
OVERTIME_DAYS = 10,
TTID_TIME_BEGIN = 1417564800,
SEC_OF_ONE_DAY = 86400,

Fix_size =
    fun FUN(Bin, Size) when is_integer(Size) andalso bit_size(Bin) =< Size ->
        %% padding
        PadSize = Size - bit_size(Bin),
        Bin1 = <<0:PadSize, Bin/bits>>,
        %% io:format("~p ~p ~n", [Bin, Bin1]),
        Bin1;
    FUN(Bin, Size) when is_integer(Size) ->
        %% truncating
        Size1 = bit_size(Bin) - Size,
        <<_:Size1, Bin1/bits>> = Bin,
        %% io:format("~w ~p ~w ~p ~n", [Bin, bit_size(Bin), Bin1, bit_size(Bin1)]),
        Bin1
    end,

Bin_to_unsigned =
    fun(Bin) ->
        Size = bit_size(Bin),
        Size1 = case Size rem 8 of
                     0 ->
                         Size;
                     _ ->
                         (Size div 8 + 1 ) * 8
                 end,
        Bin1 = Fix_size(Bin, Size1),
        binary:decode_unsigned(Bin1)
    end,

Get_time_from_mid =
    fun(Mid, _CurTime = {CurMegaSec, CurSec, _CurMicroSec}) ->
        MidBin = binary:encode_unsigned(binary_to_integer(Mid)),
        %% about the record, please refer to ticktick
        case MidBin of
            <<_VerB:2/bits, SecB:30/bits, _MSecB:10/bits, _SeqB:10/bits, _MachB:10/bits, _TagB:2/bits>> ->
                Bin_to_unsigned(SecB) + TTID_TIME_BEGIN;
            _Other ->
                %io:format("Wrong format Mid: ~p~n", [Mid]),
                CurMegaSec * 1000000 + CurSec
        end
    end,

Is_mid_overtime =
    fun(Mid, CurTime = {CurMegaSec, CurSec, _CurMicroSec}) ->
        %io:format("Mid: ~p~n", [Mid]),
        Seconds = Get_time_from_mid(Mid, CurTime),
        DaysFromNow = (CurMegaSec * 1000000 + CurSec - Seconds) div SEC_OF_ONE_DAY,
        %io:format("MID: ~p, DaysFromNow: ~p, sec: ~p~n", [MID, DaysFromNow, (CurMegaSec * 1000000 + CurSec - Seconds) rem SEC_OF_ONE_DAY]),
        DaysFromNow > OVERTIME_DAYS
    end,

Get_mids =
    fun(IndexUnreadKey) ->
        W = cuesport:get_worker(index),
        try
            case eredis:q(W, [lrange, IndexUnreadKey, 0, -1], REDIS_TIMEOUT) of
                {ok, undefined} ->
                    [];
                {ok, List} when is_list(List) ->
                    List;
                Error ->
                    io:format("lrange IndexUnreadKey: ~p error: ~p~n", [IndexUnreadKey, Error]),
                    []
            end
        catch
            Class:Exception ->
                io:format("lrange IndexUnreadKey: ~p: Class:~p Exception:~p StackTrace:~p~n",
                            [IndexUnreadKey, Class, Exception, erlang:get_stacktrace()]),
                []
        end
    end,

Exec_redis_hdel =
    fun(Key, Field) ->
        W = cuesport:get_worker(index),
        try 
            case eredis:q(W, [hdel, Key, Field], REDIS_TIMEOUT) of
                {ok, undefined} ->
                    ok; 
                {ok, _Int} ->
                    ok; 
                Error ->
                    io:format("hdel key: ~p, field: ~p error: ~p~n", [Key, Field, Error]),
                    {error, Error}
            end 
        catch
            Class:Exception ->
                io:format("hdel key: ~p, field: ~p, Class:~p Exception:~p StackTrace:~p~n",
                            [Key, Field, Class, Exception, erlang:get_stacktrace()]),
                {error, Exception}
        end
    end,

Exec_redis_del =
    fun(Key) ->
        W = cuesport:get_worker(index),
        try 
            case eredis:q(W, [del, Key], REDIS_TIMEOUT) of
                {ok, undefined} ->
                    ok; 
                {ok, _Int} ->
                    ok; 
                Error ->
                    io:format("del key: ~p, error: ~p~n", [Key, Error]),
                    {error, Error}
            end 
        catch
            Class:Exception ->
                io:format("del key: ~p, Class:~p Exception:~p StackTrace:~p~n",
                            [Key, Class, Exception, erlang:get_stacktrace()]),
                {error, Exception}
        end
    end,

Delete_zero_cid_and_index =
    fun(<<"unread:", Jid/binary>> = UnreadKey, Cid, "dry_run") ->
        io:format("[deleted]UnreadKey: ~p, Cid: ~p~n", [UnreadKey, Cid]),
        io:format("[deleted]index unread key: ~p~n", [easemob_offline_index:get_index_key(Jid, Cid)]);
    (<<"unread:", Jid/binary>> = UnreadKey, Cid, "delete") ->
        io:format("[deleted]UnreadKey: ~p, Cid: ~p~n", [UnreadKey, Cid]),
        Exec_redis_hdel(UnreadKey, Cid),
        io:format("[deleted]index unread key: ~p~n", [easemob_offline_index:get_index_key(Jid, Cid)]),
        Exec_redis_del(easemob_offline_index:get_index_key(Jid, Cid));
    (_UnreadKey, _CID, RunMode) ->
        io:format("[Delete_zero_cid_and_index]wrong RunMode: ~p~n", [RunMode])
    end,

Do_Delete_overtime_mid =
    fun(_Jid, _Cid, Mid, "dry_run") ->
        io:format("[deleted]Mid: ~p~n", [Mid]);
    (Jid, Cid, Mid, "delete") ->
        message_store:delete_message(Jid, Cid, Mid);
    (_Jid, _Cid, _Mid, RunMode) ->
        io:format("[Do_Delete_overtime_mid]wrong RunMode: ~p~n", [RunMode])
    end,

Delete_overtime_mid =
    fun(<<"unread:", Jid/binary>> = UnreadKey, Cid, RunMode) ->
        %io:format("Jid: ~p, Cid: ~p~n", [Jid, Cid]),
        IndexUnreadKey = easemob_offline_index:get_index_key(Jid, Cid),
        MidList = Get_mids(IndexUnreadKey),
        case MidList of
            [] ->
                Delete_zero_cid_and_index(UnreadKey, Cid, RunMode);
            _ ->
                lists:foreach(fun(Mid) ->
                    case Is_mid_overtime(Mid, os:timestamp()) of
                        true ->
                            Do_Delete_overtime_mid(Jid, Cid, Mid, RunMode);
                        false ->
                            ignore
                    end
                end, MidList)
        end
    end,

Handle_apns_key =
    fun(ApnsKey, RunMode) ->
        case RunMode of
            "dry_run" ->
                io:format("[deleted]ApnsKey: ~p~n", [ApnsKey]);
            "delete" ->
                io:format("[deleted]ApnsKey: ~p~n", [ApnsKey]),
                Exec_redis_del(ApnsKey);
            _ ->
                io:format("[Handle_apns_key]wrong RunMode: ~p~n", [RunMode])
        end
    end,

Handle_cidpair_list =
    fun Loop(_UnreadKey, [], _RunMode) ->
        ignore;
    Loop(UnreadKey, [<<"_total">>, _TotalNumber | CidPairList], RunMode) ->
        Loop(UnreadKey, CidPairList, RunMode);
    Loop(UnreadKey, [<<"_apns">>, _Number | CidPairList], RunMode) ->
        Exec_redis_hdel(UnreadKey, <<"_apns">>),
        Loop(UnreadKey, CidPairList, RunMode);
    Loop(UnreadKey, [<<"_exist">>, _Number | CidPairList], RunMode) ->
        Exec_redis_hdel(UnreadKey, <<"_exist">>),
        Loop(UnreadKey, CidPairList, RunMode);
    Loop(<<"unread:", Jid/binary>> = UnreadKey, [Cid, NumberBinary | CidPairList], RunMode) ->
        case erlang:binary_to_integer(NumberBinary) =< 0 of
            true ->
                ignore;
            false ->
                %io:format("UnreadKey: ~p, Cid: ~p~n", [UnreadKey, Cid]),
                Delete_overtime_mid(UnreadKey, Cid, RunMode)
        end,
        Loop(UnreadKey, CidPairList, RunMode)
    end,

Scan_and_delete_unread =
    fun Loop(UnreadKey, Cursor, CidPairList, RunMode) ->
        case eredis:q(cuesport:get_worker(index), ["hscan", UnreadKey, Cursor, "count", SCAN_COUNT], REDIS_TIMEOUT) of
            {ok, [Next, undefined]} ->  % not sure if this case will happen
                Loop(UnreadKey, Next, CidPairList, RunMode);
            {ok, [<<"0">>, List]} ->
                %io:format("UnreadKey: ~p finish scanning~n", [UnreadKey]),
                Handle_cidpair_list(UnreadKey, List ++ CidPairList, RunMode);
            {ok, [Next, List]} ->
                NewList = List ++ CidPairList,
                Len = length(NewList),
                case Len > SCAN_COUNT of
                    true ->
                        %io:format("UnreadKey: ~p, Next Cursor: ~p, match cidpair list length: ~p~n", [UnreadKey, Next, Len]),
                        Handle_cidpair_list(UnreadKey, NewList, RunMode),
                        Loop(UnreadKey, Next, [], RunMode);
                    false ->
                        Loop(UnreadKey, Next, NewList, RunMode)
                 end;
            Error ->
                io:format("scan Cursor: ~p error: ~p~n", [Cursor, Error])
        end
    end,

Handle_unread_key =
    fun(UnreadKey, RunMode) ->
        Scan_and_delete_unread(UnreadKey, 0, [], RunMode)
    end,

Handle_key_list =
    fun Loop([], _RunMode) ->
        ignore;
    Loop([<<"unread:", _Jid/binary>> = UnreadKey | List], RunMode) ->
        Handle_unread_key(UnreadKey, RunMode),
        Loop(List, RunMode);
    Loop([<<"_apns:", _Jid/binary>> = ApnsKey | List], RunMode) ->
        Handle_apns_key(ApnsKey, RunMode),
        Loop(List, RunMode);
    Loop([_OtherKey | List], RunMode) ->
        Loop(List, RunMode)
    end,

Loop_scan_server =
    fun Loop(Server={RedisHost, RedisPort}, Cursor, UnreadList, RunMode) ->
        {ok, Pid} = eredis:start_link(RedisHost, RedisPort),
        case eredis:q(Pid, ["scan", Cursor, "count", SCAN_COUNT], REDIS_TIMEOUT) of
            {ok, [Next, undefined]} ->  % not sure if this case will happen
                Loop(Server, Next, UnreadList, RunMode);
            {ok, [<<"0">>, List]} ->
                io:format("Server: ~p finish scanning~n", [Server]),
                Handle_key_list(List ++ UnreadList, RunMode);
            {ok, [Next, List]} ->
                NewList = List ++ UnreadList,
                Len = length(NewList),
                case Len > SCAN_COUNT of
                    true ->
                        io:format("Server: ~p, Next Cursor: ~p, match unread list length: ~p~n", [Server, Next, Len]),
                        Handle_key_list(NewList, RunMode),
                        Loop(Server, Next, [], RunMode);
                    false ->
                        Loop(Server, Next, NewList, RunMode)
                 end;
            Error ->
                io:format("scan Cursor: ~p error: ~p~n", [Cursor, Error])
        end,
        eredis:stop(Pid)
    end,

Loop_scan_server_list =
    fun Loop([], _RunMode) ->
        ignore;
    Loop([Server | List], RunMode) ->
        Loop_scan_server(Server, 0, [], RunMode),
        Loop(List, RunMode)
    end,

Start_from_redis =
    fun(RedisHost, RedisPort, RunMode) ->
        ServerList = [{RedisHost, RedisPort}],
        io:format("ServerList: ~p~n", [ServerList]),
        Loop_scan_server_list(ServerList, RunMode)
    end,

Read_codis_redis_config =
    fun(CodisHost, CodisPort) ->
        CmdStr = "curl -s " ++ CodisHost ++ ":" ++ integer_to_list(CodisPort) ++ "/api/server_groups",
        Result = list_to_binary(os:cmd(CmdStr)),
        {Start, _Len} = binary:match(Result, <<"[">>),
        binary:part(Result, Start, byte_size(Result) - Start)
    end,

Redis_server_filter =
    fun(#{<<"type">> := <<"slave">>, <<"addr">> := Addr}) ->
        [RedisHost, RedisPort] = binary:split(Addr, <<":">>, [global]),
        {true, {binary_to_list(RedisHost), binary_to_integer(RedisPort)}};
    (_Master) ->
        false
    end,

Get_server_list =
    fun(Json) ->
        MapList = jsx:decode(Json, [return_maps]),
        lists:flatmap(fun(#{<<"servers">> := ServerMapList}) ->
            lists:filtermap(fun(#{<<"type">> := <<"slave">>, <<"addr">> := Addr}) ->
                                [RedisHost, RedisPort] = binary:split(Addr, <<":">>, [global]),
                                {true, {binary_to_list(RedisHost), binary_to_integer(RedisPort)}};
                            (_Master) ->
                                false
                            end, ServerMapList)
        end, MapList)
    end,

Start_from_codis =
    fun(CodisHost, CodisPort, RunMode) ->
        Json = Read_codis_redis_config(CodisHost, CodisPort),
        %io:format("Json: ~p~n", [Json]),
        ServerList = Get_server_list(Json),
        io:format("ServerList: ~p~n", [ServerList]),
        Loop_scan_server_list(ServerList, RunMode)
    end,

case RedisOrCodis of
    "redis" ->
        Start_from_redis(Host, list_to_integer(Port), RunMode);
    "codis" ->
        Start_from_codis(Host, list_to_integer(Port), RunMode)
end.


