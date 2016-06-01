echo(off),
[NewPoolSize0] =  Args,


{ok, PropOld} = application:get_env(msync, user),
PoolSize = proplists:get_value(pool_size, PropOld),


ProcName =
fun(Integer) ->
        list_to_atom(lists:flatten(io_lib:format("~p_~p", [msync_user,Integer])))
end,

%% get old pool size and set new pool size
NewPoolSize = list_to_integer(NewPoolSize0),
{ok, PropOld} = application:get_env(msync, user),

SetValue =
fun({pool_size, OldPoolSize}) ->
        io:format("change poolsize ~p => ~p~n", [OldPoolSize, NewPoolSize]),
        {pool_size, NewPoolSize};
   (Value) ->
        Value
end,
PropNew = lists:map(SetValue, PropOld),
application:set_env(msync,user, PropNew),

%% enable bypass mode
msync_user:auth_opt(bypassed, true),

try
    MaybeEnv = application:get_env(msync,user),
  io:format("env is ~p~n",[MaybeEnv]),
  {ok, Config} =  MaybeEnv,
  NewPoolSize = proplists:get_value(pool_size, Config),
  Servers = proplists:get_value(servers, Config),
  Bypassed = proplists:get_value(bypassed, Config, false),
  ChildSpec = {msync_user,
               {msync_user, start_link, [NewPoolSize, Servers, Bypassed]},
               permanent,
               1000,
               supervisor,
               [msync_user]
              },
  R1 = supervisor:terminate_child(msync_sup, msync_user),
  io:format("R1 = ~p~n", [R1]),
  R2 = supervisor:delete_child(msync_sup, msync_user),
  io:format("R1 = ~p~n", [R2]),
  R3 = supervisor:start_child(msync_sup, ChildSpec),
  io:format("R1 = ~p~n", [R3]),
  io:format("children: ~p~n R1 = ~p, R2 = ~p, R3 =~p~n", [supervisor:which_children(msync_sup), R1, R2, R3])
catch
    Class:Error ->
        io:format("xx  ~p:~p ~p~n", [Class, Error, erlang:get_stacktrace()])
after
    msync_user:auth_opt(bypassed, false)
end,

ok.
