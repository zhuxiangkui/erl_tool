
% input: none
%
% op: set kafka_client_module to brod
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/set_kafka_module_brod.erl

echo(on),
application:set_env(message_store, kafka_client_module, brod),
ok.
