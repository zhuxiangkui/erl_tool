%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/check_get_chatrooms.erl
%%
echo(off),
[AppKeyList] = Args,
AppKey = erlang:list_to_binary(AppKeyList),
Type = <<"chatroom">>,
Domain = <<"easemob.com">>,
Rooms = mod_easemob_cache:get_app_groups(Domain, AppKey, Type),
Room = erlang:hd(Rooms),
P1 = mod_easemob_cache_query_cmd:redis_query_cmd(get_group, Room),
P2 = mod_easemob_cache_query_cmd:redis_query_cmd(get_affiliation_scard, Room),
Ret1 = lists:map(fun(_) -> {Time1, _} = timer:tc(fun() -> mod_easemob_cache_query_cmd:redis_query(P1) end), Time1 end, lists:seq(1,10)),
io:format("get group time:~p ~n", [Ret1]),

Ret2 = lists:map(fun(_) -> {T2, _} = timer:tc(fun() -> mod_easemob_cache_query_cmd:redis_query(P1) end), T2 end, lists:seq(1,10)),
io:format("get group num time:~p ~n", [Ret2]),

Ret = timer:tc(fun() -> lists:foreach(fun(Room) -> mod_easemob_cache:get_group(Domain, Room) end, Rooms) end),

io:format("Ret:~p ~n", [Ret]),

ok.
