application:get_env(message_store, redis),

{ok, Tables} = application:get_env(message_store, redis),
PingRedis =
fun(Table) ->
        lists:foreach(
          fun({N, Pid})
                when is_pid(Pid) ->
                  try
                      timer:sleep(10),
                      {state, Host, Port,_,_,_,_,_,_,_} = sys:get_state(Pid),
                      case timer:tc(eredis,q,[Pid, [get,a]]) of
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
lists:foreach(PingRedis, Tables),
ok.
