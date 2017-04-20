% input: none
%
% op: get rex message_queue_len
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/get_rpc_rex_qlen.erl
%  		rex_queue_len:0

echo(off),
{message_queue_len, QLen} = process_info(whereis(rex), message_queue_len),
io:format("rex_queue_len:~p~n", [QLen]),
ok.
