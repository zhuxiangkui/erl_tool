% input: none
%
% op: restart brod kafka client
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/restart_kafka_brod.erl

echo(on),
Clients = application:get_env(message_store, kafka, []),
[begin
     easemob_kafka_sup:disconnect(Client),
     easemob_kafka_sup:connect(Client)
 end || Client <- Clients],
ok.
