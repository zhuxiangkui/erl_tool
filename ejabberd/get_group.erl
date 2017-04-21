% input: GroupId
%
% op: get status of GroupId
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd' ejabberd/get_group.erl easemob-demo#chatdemoui_1492069834887
%		detail = {ok,[<<"title">>,<<"Party_Bos">>,<<"description">>,<<"aas">>,
%              	<<"public">>,<<"false">>,<<"members_only">>,<<"true">>,
%              	<<"allow_user_invites">>,<<"false">>,<<"max_users">>,<<"200">>,
%              	<<"last_modified">>,<<"1492661611655">>,<<"type">>,<<"group">>,
%             	<<"created">>,<<"1492152321152">>,<<"owner">>,
%              	<<"easemob-demo#chatdemoui_na1">>]}
%Affiliations in DB: 4
%		easemob-demo#chatdemoui_na3
%		easemob-demo#chatdemoui_na1
%		easemob-demo#chatdemoui_na2
%		easemob-demo#chatdemoui_na4
%mute: {ok,[]}
%outcast: {ok,[]}
%the group process is not alive

echo(off),
[GroupId] = Args,
Worker = mod_easemob_cache_query_cmd:client(any),
sys:get_state(Worker),
Detail = eredis:q(Worker, [hgetall, iolist_to_binary(["im:", GroupId])]),
io:format("detail = ~p~n",[Detail]),
case eredis:q(Worker, [zrange, iolist_to_binary(["im:", GroupId, ":affiliations"]), 0, -1]) of
    {ok, Affx} ->
	io:format("Affiliations in DB: ~p~n", [erlang:length(Affx)]),
	lists:foreach(fun(People) ->
			      io:format("\t~s~n", [People])
		      end, Affx);
    En ->
	io:format("error = ~p~n",[ En ])
end,

io:format("mute: ~p~n", [eredis:q(Worker, [zrange, iolist_to_binary(["im:", GroupId, ":mute"]), 0, -1])]),
io:format("outcast: ~p~n", [eredis:q(Worker, [zrange, iolist_to_binary(["im:", GroupId, ":outcast"]), 0, -1])]),
case muc_mnesia:rpc_get_online_room(iolist_to_binary([GroupId]), <<"conference.easemob.com">>) of
    [{_,_,Pid}] ->
	io:format("group process ~p @ ~p ~n", [Pid, node(Pid)]),
	case rpc:call(node(Pid), sys,get_state,[Pid]) of
	    {_FsmState, State} ->
		Aff = dict:to_list(element(11,State)),
		io:format("Affiliations in mem: ~p~n", [erlang:length(Aff)]),
		lists:foreach(fun(P2) ->
				      io:format("\t~p~n", [P2])
			      end, Aff);
	    Else ->
		io:format("error = ~p~n", [Else])
	end;
    _ ->
	io:format("the group process is not alive~n",[])
end.
