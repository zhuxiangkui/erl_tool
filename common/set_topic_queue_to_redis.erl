
% input: none
%
% op: kafka double channel, change to auxiliary channel
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/set_topic_queue_to_redis.erl

echo(on),
application:set_env(message_store, queue_log_module, redis),
ok.
