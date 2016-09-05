% input: none
%
% op: measure redis visit time
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/ping_redis.erl

echo(off),
{A, B, C} = os:timestamp(),
random:seed(A, B, C),

{ok, Tables} = application:get_env(message_store, redis),

PingRedis =
fun(Table) ->
        lists:foreach(
          fun({N, Pid})
                when is_pid(Pid) ->
                  try
                      timer:sleep(10),
		      Key = iolist_to_binary(io_lib:format("~p", [random:uniform()])),
                      {state, Host, Port,_,_,_,_,_,_,_} = sys:get_state(Pid),
		      put(host, Host),
		      put(port, Port),
                      case timer:tc(eredis,q,[Pid, [get, Key]]) of
                          {Time, {ok, _}} ->
                              io:format("~w ~w ~s:~w ~w ~w ~w~n",[node(), Table, Host, Port, Time/1000, N,Pid]),
                              ok;
                          {Time, Value} ->
                              io:format("~w ~w ~s:~w ~w ~w ~w~n",[node(), Table, Host, Port, 50000, N,Pid])
                      end
                  catch
                      Class:Type ->
                              io:format("~w ~w ~s:~w ~w ~w ~w~n",[node(), Table, get(host), get(port), 60000, N,Pid])
                  end;
             (_) ->
                  false
          end,
          ets:tab2list(Table))
end,

ModName  =
fun (Mod) ->
	list_to_atom(atom_to_list(Mod) ++ "_easemob.com")
end,

TableExists =
fun(EtsTableName) ->
	io:format("~p~n", [EtsTableName]),
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
