% input: true | false
%
% op: set enable_thrift_group of app config
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/set_thrift_group.erl true 

echo(off),
Bool =
case Args of
    ["true"] ->
        true;
    ["false"] ->
        false;
    _ ->
        bad_args
end,
case Bool == bad_args of
    true ->
        io:format("Error: you should input args like: true or false ~n", []);
    false ->
        application:set_env(message_store, enable_thrift_group, Bool),
        io:format("you have set thrift group :~p ~n", [Bool])
end,
ok.
