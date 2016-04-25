echo(off),
lists:foreach(
  fun({Type,Nodes}) ->
	  NewNodes = lists:filter(
		       fun(Node) ->
			       lists:member(Node, nodes())
		       end, Nodes),
	  io:format("new nodes ~p ~p~n", [Type, NewNodes]),
	  io:format("removed nodes ~p ~p~n", [Type, NewNodes -- Nodes]),
	  ejabberd_store:set_store_nodes(Type, NewNodes)
  end, application:get_env(msync,store_nodes,[])).

