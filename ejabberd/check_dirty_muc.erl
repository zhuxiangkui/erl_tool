timer:sleep(10000),
lists:foreach(
  fun({_,{Name, Host},Pid}) ->
	  case rpc:call(node(Pid), erlang, is_process_alive, [Pid]) of
	      true ->
		  ok;
	      _ ->
		  muc_mnesia:rpc_delete_online_room(Host, Name, Pid),
		  io:format("~p @ ~p is dirty~n", [Name, node(Pid)])
	  end
  end, muc_mnesia:rpc_get_vh_rooms(<<"conference.easemob.com">>)).
