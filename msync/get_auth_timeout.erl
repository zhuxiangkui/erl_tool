echo(off),
Timeout = application:get_env(msync, user_auth_timeout, 500),
io:format("auth timeout = ~p~n",[Timeout]),
ok.
