% input: AppKeyList
%
% op: check the delay of get chatroom
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-59-pri ejabberd/check_get_chatrooms.erl easemob-demo#chatdemoui
%		get group time:[2691,2494,2188,2207,2726,2524,2316,2512,2439,2583] 
%		get group num time:[2673,2572,2350,4100,2590,2629,2576,2385,2636,2339] 
%		Ret:{3363411,ok}

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
