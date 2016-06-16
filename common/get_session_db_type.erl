echo(off),
Type = application:get_env(ejabberd, session_db_type, mnesia),
io:format("session_db_type = ~p~n",[Type]),
ok.
