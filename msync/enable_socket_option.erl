lists:foreach(
  fun({Option, Value}) ->
	  F = fun(Socket)
		    when is_port(Socket) ->
		      Opts = inet:getopts(Socket, [Option]),
		      case Opts of
			  {ok,[{Option,Value}]} ->
			      false;
			  _ ->
			      {true, Socket}
		      end;
		 (_) ->
		      false
	      end,
	  lists:foreach(
	    fun (Socket) ->
		    {{S1,S2,S3,S4}, P1} = try
					      case inet:peername(Socket) of
						  {ok, {Host, Port} } -> {Host, Port}
					      end
					  catch
					      _:_ -> {{0,0,0,0}, 0}
					  end,
		    MaybeJID = msync_c2s_lib:get_socket_prop(Socket,pb_jid),
		    inet:setopts(Socket, [{Option, Value}]),
		    Opts = inet:getopts(Socket, [Option]),
		    io:format("JID = ~p, Socket = ~p ~p.~p.~p.~p:~p ~p = ~p Opts=~p~n", [MaybeJID, Socket, S1,S2,S3,S4, P1, Option, Value, Opts])
	    end, 
	    lists:filtermap(F, element(2, process_info(whereis(msync_c2s), links))) ++
		lists:filtermap(F, element(2, process_info(whereis(msync_server), links)))
	   ),
	  ok
  end, 
  [{keepalive, true}, 
   {nodelay, true}, 
   {buffer, 1460},
   {recbuf, 4096},
   {send_timeout, 15000}]),
supervisor:restart_child(msync_sup, msync_server).

