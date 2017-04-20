% input: write | read | close_write | close_read
%
% op: ssdb control
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 common/set_ssdb.erl write

echo(off),

[OP] = Args,
case OP of
    % double write ssdb / mysql
    "write" ->
        application:set_env(message_store, enable_mysql_body_write, true),
        application:set_env(message_store, enable_mysql_body_read, true),
        application:set_env(message_store, enable_ssdb_body_write, true),
        application:set_env(message_store, enable_ssdb_body_read, false);
    % read ssdb only
    % double write ssdb / mysql
    "read" ->
        application:set_env(message_store, enable_mysql_body_write, true),
        application:set_env(message_store, enable_mysql_body_read, false),
        application:set_env(message_store, enable_ssdb_body_write, true),
        application:set_env(message_store, enable_ssdb_body_read, true);
    % close write ssdb
    % close read ssdb
    "close_write" ->
        application:set_env(message_store, enable_mysql_body_write, true),
        application:set_env(message_store, enable_mysql_body_read, true),
        application:set_env(message_store, enable_ssdb_body_write, false),
        application:set_env(message_store, enable_ssdb_body_read, false);
    % close read ssdb
    % double write ssdb / mysql
    "close_read" ->
        application:set_env(message_store, enable_mysql_body_write, true),
        application:set_env(message_store, enable_mysql_body_read, true),
        application:set_env(message_store, enable_ssdb_body_write, true),
        application:set_env(message_store, enable_ssdb_body_read, false);
end.
