
% input: none
%
% op: get current kafka_client_module, brod or ekaf
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_kafka_module.erl

echo(on),
application:get_env(message_store, kafka_client_module),
ok.
