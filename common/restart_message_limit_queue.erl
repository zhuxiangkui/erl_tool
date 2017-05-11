% input: none
%
% op: restart message limit queue consumer
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/restart_message_limit_queue.erl

echo(on),
easemob_message_limit_queue_sup:stop(),
easemob_message_limit_queue_sup:start(),
ok.
