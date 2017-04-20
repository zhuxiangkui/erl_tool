% input: none
%
% op: stop odbc, use ssdb instead
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/stop_odbc_shard.erl

echo(on),
config_odbc_shards:stop_shard(),
application:set_env(message_store, odbc_shard_conn_switch, false),
application:set_env(message_store, enable_mysql_index, false),
application:set_env(message_store, enable_mysql_body_write, false),
application:set_env(message_store, enable_mysql_body_read, false),
application:set_env(message_store, enable_ssdb_body_write, true),
application:set_env(message_store, enable_ssdb_body_read, true),
ok.

