echo(off),
io:format("~p ~p ~p~n",[node(),msync_c2s_guard:get_num_of_workers(), ets:info(msync_c2s_tbl_sockets, size)]),
ok.

