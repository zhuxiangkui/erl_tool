[User, App, Org] =
case Args of
    [_, _, _] -> Args;
    [_, _] -> [Args] ++ ["easemob-demo"];
    [_] -> [Args] ++ [ "chatdemoui", "easemob-demo"]
end,
AppKey = [Org, "#", App],

Worker = mod_easemob_cache_query_cmd:client(any),
sys:get_state(Worker),
eredis:q(Worker, [hgetall, iolist_to_binary(["im:", AppKey, "_" , User])]),
case eredis:q(Worker, [zrange, iolist_to_binary(["im:", AppKey, "_" , User, ":affiliations"]), 0, -1]) of
    {ok, Affx} ->
	io:format("Affiliations: ~p, ~p~n", [erlang:length(Affx), Affx]);
    En ->
	En
end,

eredis:q(Worker, [zrange, iolist_to_binary(["im:", AppKey, "_" , User, ":mute"]), 0, -1]),
eredis:q(Worker, [zrange, iolist_to_binary(["im:", AppKey, "_" , User, ":outcast"]), 0, -1]),
case muc_mnesia:rpc_get_online_room(iolist_to_binary([AppKey,"_", User]), <<"conference.easemob.com">>) of
    [{_,_,Pid}] ->
	io:format("~p @ ~p ~p~n", [Pid, node(Pid), mod_muc_room:get(Pid, pq_size)]),
	case rpc:call(node(Pid), sys,get_state,[Pid]) of
	    {_FsmState, State} ->
		Aff = dict:to_list(element(11,State)),
		io:format("Affiliations: ~p, ~p~n", [erlang:length(Aff), Aff]);
	    Else -> Else
	end;
    _ ->
	ok
end.



