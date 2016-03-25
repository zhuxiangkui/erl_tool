application:get_env(message_store, redis),

{ok, Tables} = application:get_env(message_store, redis),
PingRedis =
fun(Table) ->
        io:format("checking ~p on ~p~n",[ Table, node() ]),
        lists:foreach(
          fun({N, Pid})
                when is_pid(Pid) ->
                  try
                      case eredis:q(Pid, [get,a]) of
                          {ok, _} ->
                              io:format("info: N=~p, Pid=~p ok~n",[N,Pid]),
                              ok;
                          Value ->
                              io:format("error: unexpected value N=~p, Pid=~p, Value=~p~n",
                                        [N,Pid,Value])
                      end
                  catch
                      Class:Type ->
                              io:format("error: ~p:~p unexpected value N=~p, Pid=~p~n",
                                        [Class,Type, N,Pid])
                  end;
             (_) ->
                  false
          end,
          ets:tab2list(Table))
end,
lists:foreach(PingRedis, Tables),
ok.
