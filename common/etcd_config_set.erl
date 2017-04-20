% input: Prefix Appname Key(option)
%
% op: set configure info into etcd server
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-88 -setcookie secret common/etcd_config_get.erl "/imstest/vip1/msync/workerconfig/all" "msync" "httpc_timeout" "30000"
%       ./erl_expect -sname ejabberd@ebs-ali-beijing-88 -setcookie secret common/etcd_config_get.erl "/imstest/vip1/msync/workerconfig/all" "message_store" "log" "[{host, \"redis\"},{port, 6379},{db, 0},{pool_size, 1}]"
%
% note: run in ejabberd/msync nodes

echo(off),

case Args of
    [Prefix, AppName, Key, Value] ->
        io:format("~p~n", [etcdc:set(filename:join([Prefix, AppName, Key]), Value)]);
    _ ->
        io:format("~p~n", [{error, args_error}])
end,
ok.