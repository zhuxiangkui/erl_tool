% input: none
%
% op: kill the processes of odbc whose message_queue_len is large than 500
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/kill_odbc_do_recv.erl

lists:foreach(
  fun(P) ->
	  try process_info(P, [current_stacktrace,message_queue_len]) of
	      [{current_stacktrace,
		[{p1_mysql_conn,do_recv,3,
		  [{file,"src/p1_mysql_conn.erl"},
		   {line,251}]},
		 {p1_mysql_conn,get_query_response,4,
		  [{file,"src/p1_mysql_conn.erl"},
		   {line,472}]},
		 {p1_mysql_conn,loop,1,
		  [{file,"src/p1_mysql_conn.erl"},
		   {line,346}]}]},
	       {message_queue_len,Len}] when Len > 500 ->
		  io:format("kill ~p~n", [P]),
		  exit(P, kill);
	      _ ->
		  ok
	  catch 
	      _:_ ->
		  ok
	  end
  end, erlang:processes()).
