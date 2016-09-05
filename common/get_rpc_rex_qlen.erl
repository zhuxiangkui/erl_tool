
% input: none
%
% op: get rex message_queue_len
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_rpc_rex_qlen.erl

echo(off),
{message_queue_len, QLen} = process_info(whereis(rex), message_queue_len),
io:format("rex_queue_len:~p~n", [QLen]),
ok.
