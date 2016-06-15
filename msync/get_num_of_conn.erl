echo(off),
io:format("~p: ~p connections~n",[node(),ets:info(msync_c2s_tbl_sockets, size)]),
ok.
