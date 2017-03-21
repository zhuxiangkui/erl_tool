
%%%
% feature: set configure info into etcd server
% params : Prefix, Appname, Key, value
% example: ./erl_expect -sname ejabberd@ebs-ali-beijing-88 -setcookie secret ejabberd/etcd_config_get.erl "/imstest/vip1/msync/workerconfig/all" "msync" "httpc_timeout" "30000"
%          ./erl_expect -sname ejabberd@ebs-ali-beijing-88 -setcookie secret ejabberd/etcd_config_get.erl "/imstest/vip1/msync/workerconfig/all" "message_store" "log" "[{host, \"redis\"},{port, 6379},{db, 0},{pool_size, 1}]"
% note   : 在某一台msync/ejabberd 节点上执行即可
%%%


echo(off),

case Args of
    [Prefix, AppName, Key, Value] ->
        io:format("~p~n", [etcdc:set(filename:join([Prefix, AppName, Key]), Value)]);
    _ ->
        io:format("~p~n", [{error, args_error}])
end,
ok.