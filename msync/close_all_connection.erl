[Interval0] = Args,
Interval = list_to_integer(Interval0),
msync_server:stop(),
lists:foreach(
  fun(Socket) when is_port(Socket) ->
	  JID = msync_c2s_lib:get_socket_prop(Socket,pb_jid),
	  io:format("~p~n", [JID]),
	  if element(1,JID) == 'JID' ->
		  io:format("closing ~p for ~s~n", [Socket, msync_msg:pb_jid_to_binary(JID)]);
	     true ->
		  io:format("closing ~p for ~p~n", [Socket, JID])
	  end,
	  msync_c2s_lib:maybe_close_session(Socket),
	  gen_tcp:close(Socket);
     (Other)  ->
	  io:format("ignore ~p~n", [Other])
  end,
  element(2, process_info(whereis(msync_c2s),links))).

