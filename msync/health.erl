echo(off),
{A, B, C} = os:timestamp(),
random:seed(A, B, C),

SysInfo =
fun() ->
	Infos = [
		 process_count,
		 process_limit,
		 port_count,
		 port_limit
		],
	lists:foreach(fun(Id) ->
			      io:format("~p:~p~n", [Id, erlang:system_info(Id)])
		      end, Infos),
	lists:foreach(
	  fun ({Type, Size}) ->
		  io:format("mem_~p:~p~n",[Type,Size])
	  end,
	  erlang:memory())
end,

ConnNum =
fun() ->
	io:format("num_of_connected_users:~p~n",[ets:info(msync_c2s_tbl_sockets, size)]),
	io:format("num_of_sockets:~p~n", [erlang:length(element(2, process_info(whereis(msync_c2s), links)))])
end,

WorkerNum =
fun() ->
	io:format("num_of_workers:~p~n", [msync_c2s_guard:get_num_of_workers()])
end,


GetRedisDelay = 
fun(Table) ->
        lists:foldl(
          fun({N, Pid}, {Max, Min, Avg, Count}) 
                when is_pid(Pid) ->
                  try
                      timer:sleep(1),
		      Key = iolist_to_binary(io_lib:format("~p", [random:uniform()])),
                      case timer:tc(eredis,q,[Pid, [get, Key]]) of
                          {Time0, {ok, _}} ->
			      Time = Time0 / 1000,
			      {max(Max, Time), min(Min, Time), (Avg * Count + Time)/(Count + 1), Count + 1};
                          {Time, Value} ->
			      {50000, Min, 50000, Count + 1}
                      end
                  catch
                      Class:Type ->
			  {50000, Min, 50000, Count + 1}
                  end;
             (_, Acc) ->
		  Acc
          end,{0,50000, 0, 0},
          ets:tab2list(Table))
end,


RedisDelay = 
fun(Table) ->
	{Max, Min, Avg, Count} = GetRedisDelay(Table),
	io:format("redis_~p_delay_max:~p~n",[Table, Max]),
	io:format("redis_~p_delay_min:~p~n",[Table, Min]),
	io:format("redis_~p_delay_avg:~p~n",[Table, Avg]),
	io:format("redis_~p_delay_count:~p~n",[Table, Count])
end,

{ok, Tables} = application:get_env(message_store, redis),
SysInfo(),
ConnNum(),
WorkerNum(),
lists:foreach(RedisDelay, Tables),

ok.

