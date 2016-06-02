echo(off),
Module = application:get_env(msync, user_auth_module, msync_user),
io:format("auth module = ~p~n",[Module]),
ok.
