%%%-------------------------------------------------------------------
%%% @author
%%% @copyright (C) 2016
%%% @doc
%%%
%%% @end
%%% Created :
%%%-------------------------------------------------------------------
-module(privacy_redis_to_pika).

%% transfer privacy from redis to pika, must run in ejabberdctl debug
%% privacy_redis_to_pika:start(Host, Port).
%% privacy_redis_to_pika:stop().

%% API
-export([
         start/4,
         start/3,
         start/2,
         stop/0,
         scan/6,
         start_repair/5,
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
-define(DEFAULT_PRIVACY, <<"special">>).
-record(privacy, {us = {<<"">>, <<"">>} :: {binary(), binary()},
                  default = none        :: none | binary(),
                  lists = []}).

-record(listitem, {type = none :: none | jid | group | subscription,
                   value = none ,
                   action = allow :: allow | deny,
                   order = 0 :: integer(),
                   match_all = false :: boolean(),
                   match_iq = false :: boolean(),
                   match_message = false :: boolean(),
                   match_presence_in = false :: boolean(),
                   match_presence_out = false :: boolean()}).
-record(privacy_cache_item, {
          none = none :: none,
          jid = <<"">> ,
          group = <<"">> :: binary(),
          subscription = none :: none | both | from | to | remove,
          action = allow :: allow | deny,
          order = 0 :: integer(),
          match_strategy =  <<"">> :: binary()}).
-record(jid, {user = <<"">> :: binary(),
              server = <<"">> :: binary(),
              resource = <<"">> :: binary(),
              luser = <<"">> :: binary(),
              lserver = <<"">> :: binary(),
              lresource = <<"">> :: binary()}).

%%%===================================================================
%%% API
%%%===================================================================

start(Host, Port) ->
    start(Host, Port, 100).

start(Host, Port, SleepTime) ->
    start(Host, Port, redis, SleepTime).

start(Host, Port, CodisOrRedis, SleepTime) ->
    scan(Host, Port, CodisOrRedis, ?RUN_MODE, [SleepTime, all], 1000000000).

start_repair(Host, Port, CodisOrRedis, SleepTime, MaxScan) ->
    scan(Host, Port, CodisOrRedis, ?RUN_MODE, [SleepTime, repair], MaxScan).

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


do_handle(List, ?RUN_MODE, [SleepTime,Action|_]) ->
    update_progress(length(List)),
    ?INFO_MSG("do_handle keys=~p",[List]),
    try
        UserList = [User||Key<-List, User<-[key_to_user(Key)], User /= skip],
        TypeQueryPipline = [[type,?PRIVACY_REDIS_KEY ++ User]||User<-UserList],
        case easemob_redis:qp(privacy, TypeQueryPipline) of
            TypeList when is_list(TypeList) ->
                GoodUserList0 = [User ||{User, {ok, <<"string">>}}<-lists:zip(UserList, TypeList)],
                OldUserList = [User ||{User, {ok, <<"hash">>}}<-lists:zip(UserList, TypeList)],
                GoodUserList = case Action of
                                   all -> GoodUserList0 ++ OldUserList;
                                   repair -> OldUserList
                               end,
                repair_privacys(OldUserList),
                QueryPipline = [[get,?PRIVACY_REDIS_KEY ++ User]||User <- GoodUserList],
                case easemob_redis:qp(privacy, QueryPipline) of
                    PrivacyList when is_list(PrivacyList) ->
                        TransferUsers = [User||
                                           {User,{ok, Value}}<-lists:zip(GoodUserList, PrivacyList),
                                           Value /= <<"[]">>, Value /= undefined],
                        WritePipline = [[set, ?PRIVACY_PIKA_KEY ++ User, Value]||
                                           {User,{ok, Value}}<-lists:zip(GoodUserList, PrivacyList),
                                           Value /= <<"[]">>, Value /= undefined],
                        %%?INFO_MSG("WritePipline:~p",[WritePipline]),
                        ?INFO_MSG("transfer cnt:~p/~p/~p,TransferUsers:~p",
                                  [length(WritePipline), length(GoodUserList), length(UserList), TransferUsers]),
                        case easemob_redis:qp(privacy_pika, WritePipline) of
                            ResList when is_list(ResList) ->
                                ok;
                            Other ->
                                ?ERROR_MSG("handle_key_list error:reason:~p,q=~p",[Other, WritePipline]),
                                ok
                        end;
                    Other ->
                        ?ERROR_MSG("handle_key_list error:reason:~p, q=~p",[Other, QueryPipline]),
                        ok
                end;
            Other ->
                ?ERROR_MSG("handle_key_list error:reason:~p, q=~p",[Other, TypeQueryPipline]),
                skip
        end
     catch
         C:E ->
             ?ERROR_MSG("handle_key_list error:error=~p, keys=~p",[{C,E,erlang:get_stacktrace()}, List])
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

repair_privacys(UserList) ->
    [try
         repair_privacy(User)
     catch
         C:E ->
             ?INFO_MSG("repair_privacy error:~p,user=~p,stacktrace=~p",[{C,E}, User, erlang:get_stacktrace()])
     end||User<-UserList],
    ok.

privacy_key(User) ->
    <<?PRIVACY_REDIS_KEY, (iolist_to_binary(User))/binary>>.

remove_privacy(User) ->
    easemob_redis:q(privacy, [del, privacy_key(User)]).

repair_privacy(User) ->
    case easemob_redis:q(privacy, ["HGETALL", privacy_key(User)]) of
        {ok, []} -> skip;
        {ok, Result} ->
            remove_privacy(User),
            ?INFO_MSG("remove_privacy_cache:user=~p,result=~p",[User, Result]),
            Ret  = parse_privacy(Result, #privacy{}),
            case lists:keyfind(?DEFAULT_PRIVACY, 1, Ret#privacy.lists) of
                false -> ignore;
                {_,[]} -> ignore;
                {_, List} ->
                    ?INFO_MSG("write_privacy_cache:user=~p, list=~p",[User, List]),
                    write_privacy(User, List)
            end,
            ok;
        _Error ->
            skip
    end.

write_privacy(LUser, List) ->
    ComposePrivacy = compose_privacy(List),
    Q = ["SET", privacy_key(LUser)]++ ComposePrivacy,
    easemob_redis:q(privacy, Q),
    ok.

parse_privacy([Key, Value | Last], Privacy) ->
	case Key of
		?DEFAULT_PRIVACY ->
			Lists = Privacy#privacy.lists,
			ListItem = parse_privacy_itemlist(mjson:decode(Value), []),
			NewPrivacy = Privacy#privacy{default = ?DEFAULT_PRIVACY, lists=[{?DEFAULT_PRIVACY, ListItem} | Lists]},
			parse_privacy(Last, NewPrivacy);
		_ ->
			parse_privacy(Last, Privacy)
	end;
parse_privacy([], Privacy) ->
	Privacy.
parse_privacy_itemlist([{struct, PrivacyItemTerm} | More], Parsed) ->
	None = proplists:get_value( <<"none">>, PrivacyItemTerm, none),
	JID = proplists:get_value( <<"jid">>, PrivacyItemTerm, <<"">>),
	Action = proplists:get_value( <<"action">>, PrivacyItemTerm, allow),
	Order = proplists:get_value( <<"order">>, PrivacyItemTerm, 0),
	Group = proplists:get_value( <<"group">>, PrivacyItemTerm, <<"">>),
	MatchStrategy = proplists:get_value( <<"match_strategy">>, PrivacyItemTerm, <<"">>),
	Subscription = proplists:get_value( <<"subscription">>, PrivacyItemTerm, none),
	PrivacyCacheItem = #privacy_cache_item{
                          none = None,
                          jid = JID,
                          group = Group,
                          subscription = Subscription,
                          action = Action,
                          order = Order,
                          match_strategy =  MatchStrategy},
	parse_privacy_itemlist(More, [transprivacycache2listitem(PrivacyCacheItem)] ++ Parsed);
parse_privacy_itemlist([], Parsed) ->
	Parsed.
transprivacycache2listitem(PrivacyCacheItem) ->
	ListItem = transstrategy2listitem(PrivacyCacheItem#privacy_cache_item.match_strategy),
	ListitemType = ListItem#listitem{
                     action=erlang:binary_to_atom(PrivacyCacheItem#privacy_cache_item.action, utf8),
                     order=PrivacyCacheItem#privacy_cache_item.order},
	JID = PrivacyCacheItem#privacy_cache_item.jid,
	Group = PrivacyCacheItem#privacy_cache_item.group,
	Subscription = PrivacyCacheItem#privacy_cache_item.subscription,

	if
		JID =/= <<"">> ->
			JIDRet = case jlib:string_to_jid(JID) of
                         error -> {<<"">>, <<"">>, <<"">>};
                         JId -> {JId#jid.user, JId#jid.server, JId#jid.resource}
                     end,
			ListitemType#listitem{type=jid, value=JIDRet};
		Group  =/= <<"">> ->
			ListitemType#listitem{type=group, value=Group};
		Subscription =/= none  ->
			ListitemType#listitem{type=jid, value=Subscription};
		true ->
			ListitemType
	end.
transstrategy2listitem(MatchStrategy) ->
	All = case lists:member(<<"all">>, MatchStrategy) of
              true ->
                  #listitem{match_all = true};
              false ->
                  #listitem{}
          end,

	IQ = case lists:member(<<"iq">>, MatchStrategy) of
             true ->
                 All#listitem{match_iq = true};
             false ->
                 All
         end,

	Message = case lists:member(<<"message">>, MatchStrategy) of
                  true ->
                      IQ#listitem{match_message = true};
                  false ->
                      IQ
              end,

	PresenceIn = case lists:member(<<"presence_in">>, MatchStrategy) of
                     true ->
                         Message#listitem{match_presence_in = true};
                     false ->
                         Message
                 end,

	PresenceOut = case lists:member(<<"presence_out">>, MatchStrategy) of
                      true ->
                          PresenceIn#listitem{match_presence_out = true};
                      false ->
                          PresenceIn
                  end,
	PresenceOut.
compose_privacy(List) ->
	R = compose_privacy_itemlist(List, []),
	[mjson:encode({array, R})].

compose_privacy_itemlist([PrivacyItem|More], Composed) ->
	RPrivacyItem = compose_privacy_item(PrivacyItem),
	compose_privacy_itemlist(More, [RPrivacyItem] ++ Composed);
compose_privacy_itemlist([], Composed) ->
	Composed.

compose_privacy_item(ListItem) ->
	PrivacyItem = listitem2privacycacheitem(ListItem),
	lists:zip(record_info(fields, privacy_cache_item), tl(tuple_to_list(PrivacyItem))) -- lists:zip(record_info(fields, privacy_cache_item), tl(tuple_to_list(#privacy_cache_item{}))).

listitem2privacycacheitem(ListItem) ->
	MatchStrategy = transmatch2strategy(ListItem),
	PrivacyCatchItem = #privacy_cache_item{
                          match_strategy = MatchStrategy,
                          action = ListItem#listitem.action,
                          order = ListItem#listitem.order},

	case ListItem#listitem.type of
		none ->
			PrivacyCatchItem;
		jid ->
			PrivacyCatchItem#privacy_cache_item{ jid = jlib:jid_to_string(ListItem#listitem.value) };
		group ->
			PrivacyCatchItem#privacy_cache_item{ group  = ListItem#listitem.value };
		subscription ->
			PrivacyCatchItem#privacy_cache_item{ subscription = ListItem#listitem.value }
	end.
transmatch2strategy(ListItem) ->
	MatchStrategyAll = case ListItem#listitem.match_all of
                           true ->
                               [] ++ [<<"all">>];
                           false ->
                               []
                       end,
	MatchStrategyIQ = case ListItem#listitem.match_iq  of
                          true ->
                              MatchStrategyAll ++ [<<"iq">>];
                          false ->
                              MatchStrategyAll
                      end,
	MatchStrategyMessage = case ListItem#listitem.match_message of
                               true ->
                                   MatchStrategyIQ ++ [<<"message">>];
                               false ->
                                   MatchStrategyIQ
                           end,

	MatchStrategyPIn = case ListItem#listitem.match_presence_in of
                           true ->
                               MatchStrategyMessage ++ [<<"presence_in">>];
                           false ->
                               MatchStrategyMessage
                       end,

	MatchStrategyPOut = case ListItem#listitem.match_presence_out of
                            true ->
                                MatchStrategyPIn ++  [<<"presence_out">>];
                            false ->
                                MatchStrategyPIn
                        end,
	MatchStrategyPOut.
