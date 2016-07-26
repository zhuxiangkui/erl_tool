%% ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 common/switch_msg_body_db_type.erl mysql

echo(off),

[DB] = Args,
case DB of
    "mysql" ->
        % write
        application:set_env(message_store, enable_ssdb_body, false),
        application:set_env(message_store, enable_mysql_body, true),
        % read
        application:set_env(message_store, message_body_database_type, mysql);
    "ssdb" ->
        % write
        application:set_env(message_store, enable_ssdb_body, true),
        application:set_env(message_store, enable_mysql_body, false),
        % read
        application:set_env(message_store, message_body_database_type, ssdb)
end.
