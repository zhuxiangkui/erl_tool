% input: none
%
% op: restart odbc shard for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/restart_odbc2.erl

echo(on),
config:load_env("/data/apps/opt/ejabberd/etc/ejabberd/message_store.config"),
easemob_odbc_sup:stop_shard(),
easemob_odbc_sup:start_shard().
