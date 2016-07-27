%% ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 common/set_ssdb.erl write

echo(off),

[OP] = Args,
case OP of
    % double write ssdb / mysql
    "write" ->
        application:set_env(message_store, enable_ssdb_body, true);
    % read ssdb only
    % double write ssdb / mysql
    "read" ->
        application:set_env(message_store, message_body_database_type, ssdb),
        application:set_env(message_store, enable_ssdb_body, true);
    % close write ssdb
    % close read ssdb
    "close_write" ->
        application:set_env(message_store, enable_ssdb_body, false),
        application:set_env(message_store, message_body_database_type, mysql);
    % close read ssdb
    % double write ssdb / mysql
    "close_read" ->
        application:set_env(message_store, message_body_database_type, mysql),
        application:set_env(message_store, enable_ssdb_body, true)
end.
