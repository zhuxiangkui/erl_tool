echo(off),
case whereis(migrate_offline_incr) of
    Pid when is_pid(Pid)->
        io:format("running ~p~n",[Pid]);
    _ ->
        io:format("stopped~n",[])
end,
ok.
