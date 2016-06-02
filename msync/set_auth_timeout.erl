echo(off),
[Timeout0] = Args,
Timeout = list_to_integer(Timeout0),
application:set_env(msync, user_auth_timeout, Timeout),
io:format("set auth timeout = ~p~n",[Timeout]),
ok.
