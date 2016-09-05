
% input: none
%
% op: kafka double channel, change to main channel
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/set_topic_queue_to_kafka.erl

echo(on),
application:set_env(message_store, queue_log_module, kafka),
ok.
