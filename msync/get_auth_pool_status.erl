{ok, PropOld} = application:get_env(msync, user),

PoolSize = proplists:get_value(pool_size, PropOld),


ProcName =
fun(Integer) ->
        list_to_atom(lists:flatten(io_lib:format("~p_~p", [msync_user,Integer])))
end,

A = lists:map(
      fun(N) ->
              {state, Servers, Workers, LstConnectTime}  = sys:get_state(ProcName(N))
      end, lists:seq(0, PoolSize -1)),

io:format("~p~n", [A]),

ok.
