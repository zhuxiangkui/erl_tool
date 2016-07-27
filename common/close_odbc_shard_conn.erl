%% ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 common/close_odbc_shard_conn.erl

echo(off),

application:set_env(message_store, odbc_shard_conn_switch, false),
application:set_env(message_store, enable_mysql_index, false),
application:set_env(message_store, enable_mysql_body, false),
application:set_env(message_store, enable_ssdb_body, true),
application:set_env(message_store, message_body_database_type, ssdb).
