[GroupId] = Args,

Worker = mod_easemob_cache_query_cmd:client(any),
sys:get_state(Worker),
eredis:q(Worker, [hgetall, iolist_to_binary(["im:", GroupId])]),
case eredis:q(Worker, [zrange, iolist_to_binary(["im:", GroupId, ":affiliations"]), 0, -1]) of
    {ok, Affx} ->
	io:format("Affiliations: ~p, ~p~n", [erlang:length(Affx), Affx]);
    En ->
	En
end,

eredis:q(Worker, [zrange, iolist_to_binary(["im:", GroupId, ":mute"]), 0, -1]),
eredis:q(Worker, [zrange, iolist_to_binary(["im:", GroupId, ":outcast"]), 0, -1]),
case muc_mnesia:rpc_get_online_room(iolist_to_binary([GroupId]), <<"conference.easemob.com">>) of
    [{_,_,Pid}] ->
	io:format("group process ~p @ ~p ~n", [Pid, node(Pid)]),
	case rpc:call(node(Pid), sys,get_state,[Pid]) of
	    {_FsmState, State} ->
		Aff = dict:to_list(element(11,State)),
		io:format("Affiliations: ~p, ~p~n", [erlang:length(Aff), Aff]);
	    Else -> Else
	end;
    _ ->
	ok
end.
