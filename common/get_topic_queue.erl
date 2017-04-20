% input: none
%
% op: get config of 'queue_log_module' 
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_topic_queue.erl
%		kafka

echo(off),
io:format("~p~n", [application:get_env(message_store, queue_log_module, kafka)]),
ok.
