echo(off),
Type = ejabberd_sm:get_session_db_type(),
io:format("session_db_type = ~p~n",[Type]),
ok.
