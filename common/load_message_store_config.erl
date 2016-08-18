% input: none
%
% op: restart odbc shard for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/load_message_store_config.erl

echo(off),
config:load_env("/data/apps/opt/ejabberd/etc/ejabberd/message_store.config"),
ok.
