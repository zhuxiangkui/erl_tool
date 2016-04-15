application:get_env(message_store, redis),
Key = iolist_to_binary(io_lib:format("~p", [random:uniform()])),
{ok, Tables} = application:get_env(message_store, redis),
PingRedis =
fun(Table) ->
        lists:foreach(
          fun({N, Pid})
                when is_pid(Pid) ->
                  try
                      timer:sleep(10),
                      {state, Host, Port,_,_,_,_,_,_,_} = sys:get_state(Pid),
                      case timer:tc(eredis,q,[Pid, [get, Key]]) of
                          {Time, {ok, _}} ->
                              io:format("info: Table = ~p, Host=~p, Port = ~p, Resp = ~p ms, N=~p, Pid=~p ok~n",[Table, Host, Port, Time/1000, N,Pid]),
                              ok;
                          {Time, Value} ->
                              io:format("error: unexpected value, Table = ~p, Host=~p, Port = ~p, Resp = ~p ms, N=~p, Pid=~p, Value=~p~n",[Table, Host, Port, Time/1000, N,Pid, Value])
                      end
                  catch
                      Class:Type ->
                          io:format("error: ~p:~p unexpected value, Table = ~p, N=~p, Pid=~p~n",[Class, Type, Table, N,Pid])
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
			       mod_session_redis,
			       mod_message_log_redis,
			       mod_privacy_cache,
			       mod_message_cache,
			       mod_message_index_cache,
			       mod_muc_room_destroy])),
lists:foreach(PingRedis, EjabberdTables ++ Tables),

ok.
