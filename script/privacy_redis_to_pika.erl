%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016
%%% @doc
%%%
%%% @end
%%% Created :
%%%-------------------------------------------------------------------
-module(privacy_redis_to_pika).

%% delete bad user session, must run in ejabberdctl debug
%% privacy_redis_to_pika:start().
%% privacy_redis_to_pika:stop().

%% API
-export([
         start/4,
         start/0,
         start/1,
         stop/0,
         scan/6,
         scan_worker/5,
         do_scan/6,
         start_from_codis/2,
         stop_all/1,
         is_running/0,
         is_good_exit/0
]).

-define(SCAN_COUNT, 500).
-define(REDIS_TIMEOUT, 60000).
-define(INFO_MSG(Format, Args), spawn(fun()->error_logger:info_msg("~s:~p "++Format++"~n",[?MODULE, ?LINE]++Args) end)).
-define(ERROR_MSG(Format, Args), error_logger:error_msg("~s:~p "++Format++"~n",[?MODULE, ?LINE]++Args)).

-define(RUN_MODE, privacy_redis_to_pika).
-define(PRIVACY_REDIS_KEY, "im:privacyv2:").
-define(PRIVACY_PIKA_KEY, "im:privacy:pika:").

%%%===================================================================
%%% API
%%%===================================================================

start() ->
    start(no_host, no_port, redis, 100).

start(SleepTime) ->
    start(no_host, no_port, redis, SleepTime).

start(Host, Port, CodisOrRedis, SleepTime) ->
    scan(Host, Port, CodisOrRedis, ?RUN_MODE, [SleepTime], 1000000000).

stop() ->
    stop_all(?RUN_MODE).

is_running() ->
    Pids = application:get_env(message_store, {codis_scan_pid_list, ?RUN_MODE}, []),
    case [Pid||Pid<-Pids, is_process_alive(Pid)] of
        [] ->
            false;
        _ ->
            true
    end.

is_good_exit() ->
    Pids = application:get_env(message_store, {codis_scan_pid_list, ?RUN_MODE}, []),
    case [Pid||Pid<-Pids, 
            not is_process_alive(Pid), 
            application:get_env(message_store, {codis_scan_result, ?RUN_MODE, Pid}, exit) /= ok] of
        [] -> true;
        _ ->
            false
    end.

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
    [begin
         application:unset_env(message_store, {codis_scan_result, RunMode, OldPid}),
         exit(OldPid, kill)
     end||OldPid<-application:get_env(message_store, {codis_scan_pid_list, RunMode}, [])],
    application:unset_env(message_store, {codis_scan_pid_list, RunMode}),
    ok.

scan_worker(RedisHost, RedisPort, RunMode, RunArgs, MaxScan) ->
    proc_lib:spawn(?MODULE, do_scan, [RedisHost, RedisPort, RunMode, RunArgs, 0, MaxScan]).

do_scan(RedisHost, RedisPort, RunMode, RunArgs, Cursor, MaxScan) when MaxScan > 0 ->
    {Now,Max} = get_progress(),
    ?INFO_MSG("do scan:cursor=~p, progress=~p/~p(~.2f%)",[Cursor, Now, Max, (Now*100/max(1,Max))]),
    case scan_key_list(RedisHost, RedisPort, Cursor) of
        {ok, finish, List} ->
            do_handle(List, RunMode, RunArgs),
            ?INFO_MSG("Scan finish with finish:s=~p", [ {RedisHost,RedisPort}]),
            application:set_env(message_store, {codis_scan_result, RunMode, self()}, ok),
            ok;
        {ok, Next, List}->
            do_handle(List, RunMode, RunArgs),
            ?MODULE:do_scan(RedisHost, RedisPort, RunMode, RunArgs, Next, MaxScan-1);
        {error, Error} ->
            ?INFO_MSG("Scan finish with Error:~p,s=~p", [Error, {RedisHost,RedisPort}]),
            application:set_env(message_store, {codis_scan_result, RunMode, self()}, {error, Error}),
            {error, Error}
    end;
do_scan(RedisHost, RedisPort, RunMode, _RunArgs, _Cursor, _MaxScan) ->
    ?INFO_MSG("Scan finish with :~p,s=~p", [max_scan, {RedisHost,RedisPort}]),
    application:set_env(message_store, {codis_scan_result, RunMode, self()}, ok),
    ok.


do_handle(List, ?RUN_MODE, [SleepTime]) ->
    update_progress(length(List)),
    ?INFO_MSG("do_handle keys=~p",[List]),
    try
        UserList = [User||Key<-List, User<-[key_to_user(Key)], User /= skip],
        QueryPipline = [[get,?PRIVACY_REDIS_KEY ++ User]||User<-UserList],
        case easemob_redis:qp(privacy, QueryPipline) of
            PrivacyList when is_list(PrivacyList) ->
                WritePipline = [[set, ?PRIVACY_PIKA_KEY ++ User, Value]||
                                   {User,{ok, Value}}<-lists:zip(UserList, PrivacyList),
                                   Value /= <<"[]">>],
                %?INFO_MSG("WritePipline:~p",[WritePipline]),
                easemob_redis:qp(privacy_pika, WritePipline);
            _ ->
                ok
        end
     catch
         C:E ->
             ?ERROR_MSG("handle_key_list error:keys=~p, error=~p",[List, {C,E,erlang:get_stacktrace()}])
     end,
    if
        SleepTime > 0 ->
            timer:sleep(SleepTime);
        true ->
            skip
    end,
    ok.

key_to_user(Key) ->
    case binary_to_list(Key) of
        ?PRIVACY_REDIS_KEY ++ Rest when length(Rest) > 0 ->
            Rest;
        _ ->
            skip
    end.

get_progress() ->
    maybe_init_progress(),
    Now = get({now_progress,?MODULE}),
    Max = get({max_progress,?MODULE}),
    {Now,Max}.

maybe_init_progress() ->
    case get({max_progress,?MODULE}) of
        undefined ->
            {ok, KeySpace} = easemob_redis:q(privacy,[info,keyspace]),
            ["# Keyspace","db0:keys",KeyNumStr|_] =  string:tokens(binary_to_list(KeySpace), "\r\n,="),
            put({now_progress,?MODULE}, 0),
            put({max_progress,?MODULE}, list_to_integer(KeyNumStr)),
            ok;
        _ ->
            skip
    end.

update_progress(Num) ->
    maybe_init_progress(),
    Old = get({now_progress,?MODULE}),
    put({now_progress,?MODULE}, Old+Num),
    ok.

scan_key_list(RedisHost, RedisPort, Cursor) ->
    try
        Res =
            case easemob_redis:q(privacy, ["scan", Cursor, "count", ?SCAN_COUNT]) of
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
