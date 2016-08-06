echo(off),
{A, B, C} = os:timestamp(),
random:seed(A, B, C),

{ok, Tables} = application:get_env(message_store, redis),


PingRedisWorker = 
fun(Table, N, Pid) ->
	try
	    Key = iolist_to_binary(io_lib:format("~p", [random:uniform()])),
	    {state, Host, Port,_,_,_,_,_,_,_} = sys:get_state(Pid),
	    put(host, Host),
	    put(port, Port),
	    case timer:tc(eredis,q,[Pid, [get, Key]]) of
		{Time, {ok, _}} when Time < 20000->
		    ok;
		{Time, {ok, _}} ->
		    io:format("warning: ~w ~w ~s:~w ~w ~w ~w~n",[node(), Table, Host, Port, Time/1000, N,Pid]),
		    ok;
		{Time, Value} ->
		    io:format("error: ~w ~w ~s:~w ~w ~w ~w~n",[node(), Table, Host, Port, 50000, N,Pid])
	    end
	catch
	    Class:Type ->
		exit(Pid, kill),
		io:format("error: ~w ~w ~s:~w ~w ~w ~w~n",[node(), Table, get(host), get(port), 60000, N,Pid])
	end
end,

PingRedis =
fun(Table) ->
	PingRedisN = 
	    fun(N) ->
		    try ets:lookup(Table, N) of
			[{N, Worker}] ->
			    PingRedisWorker(Table, N, Worker)
		    catch
			C2:E2 ->
			    io:format("error:~p ~p:~p no worker for N = ~p, Table = ~p~n", [node(), C2, E2, N, Table])
		    end
	    end,
	try 
	    ets:lookup(Table, pool_size) of
	    [{pool_size, PoolSize}]  ->
		lists:foreach(PingRedisN, lists:seq(1, PoolSize))
	catch
	    C1:E1 ->
		io:format("error:~p ~p:~p message_store is not started, no worker pool of ~p~n", [node(), C1, E1, Table])
	end
end,

ModName  =
fun (Mod) ->
	list_to_atom(atom_to_list(Mod) ++ "_easemob.com")
end,

TableExists =
fun(EtsTableName) ->
	case ets:info(EtsTableName) of
	    undefined ->
		false;
	    _ ->
		true
	end
end,

EjabberdTables = lists:filter(
		   TableExists,
		   lists:map(ModName,
			     [ mod_easemob_cache,
                               mod_roster_cache,
			       mod_session_redis,
			       mod_message_log_redis,
			       mod_privacy_cache,
			       mod_message_cache,
			       mod_message_index_cache,
			       mod_muc_room_destroy])),
lists:foreach(PingRedis, EjabberdTables ++ Tables),

ok.
