% input: full_large_group true
%	 full_large_group false
%	 read_group_cursor true
%        read_group_cursor false
%	 read_group_index true	
%	 read_group_index false
%
% op: All-app level swiches for group migration
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie 'LTBEXKHWOCIRRSEUNSYS' $ERL_TOOL_PATH/migrate_group.erl full_large_group true

echo(off),
Result =
case Args of
    ["full_large_group", "true"] ->
        application:set_env(message_store, full_large_group, true);
    ["full_large_group", "false"] ->
        application:set_env(message_store, full_large_group, false);
    ["read_group_cursor", "true"] ->
        application:set_env(message_store, read_group_cursor, true);
    ["read_group_cursor", "false"] ->
        application:set_env(message_store, read_group_cursor, false);
    ["read_group_index", "true"] ->
        application:set_env(message_store, read_group_index, true);
    ["read_group_index", "false"] ->
        application:set_env(message_store, read_group_index, false);
    _ ->
        bad_args
end,
case Result of
    bad_args ->
        io:format("Error: you should input args like: full_large_group true~n", []);
    ok ->
        io:format("Operation success~n", [])
end,
ok.
