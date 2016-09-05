% input: none
%
% op: get msync c2s child-process number
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/get_num_of_workers.erl

echo(off),
io:format("~p ~p ~p~n",[node(),msync_c2s_guard:get_num_of_workers(), ets:info(msync_c2s_tbl_sockets, size)]),
ok.

