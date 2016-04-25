echo(off),

lists:foreach(
  fun({_, Type, Nodes}) when is_list(Nodes) ->
	  {Max0, Min0, Avg0, Count0} = 
	      lists:foldl(
		fun(Node, {Max, Min, Avg, Count}) ->
			try
			    timer:sleep(1),
			    case timer:tc(rpc, call,[Node, erlang, node, [], 1000]) of
				{Time0, Node} ->
				    Time = Time0 / 1000,
				    {max(Max, Time), min(Min, Time), (Avg * Count + Time)/(Count + 1), Count + 1};
				{Time, Value} ->
				    io:format("error ~p timeout~n",[Node]),
				    {50000, Min, 50000, Count + 1}
			    end
			catch
			    Class:Type ->
				io:format("error ~p timeout~n",[Node]),
				{50000, Min, 50000, Count + 1}
			end;
		   (_, Acc) ->
			Acc
		end,{0,50000, 0, 0}, Nodes),
	io:format("db_~p_delay_max:~p~n",[Type, Max0]),
	io:format("db_~p_delay_min:~p~n",[Type, Min0]),
	io:format("db_~p_delay_avg:~p~n",[Type, Avg0]),
	io:format("db_~p_delay_count:~p~n",[Type, Count0]);
     (_) ->
	  ok
  end, ets:tab2list(store_nodes)).

