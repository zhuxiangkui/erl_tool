echo(off),
AppKeys = lists:map(fun(X) -> erlang:list_to_binary(X) end, Args),

Kick =
fun({session, {U,S,R},
     {_LoginTime, Pid},
     _US,_Priority,_Info
    }, _Acc) ->
        Appkey = app_config:get_user_appkey(U),
        case lists:member(Appkey, AppKeys) of
            true ->
                io:format("~p ~s~n", [Pid, U]),
                Pid ! system_shutdown,
                ok;
            false ->
                ok
        end
end,

try
    mnesia:activity(
      async_dirty,
      fun() ->
              mnesia:foldl(Kick, ok, session)
      end,mnesia_frag)

catch
    C:E ->
        io:format("error: ~p:~p: ~n",[C,E])
end,
ok.


