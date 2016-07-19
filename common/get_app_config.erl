%%%
% 功能：得到某一个节点的某一个 app config
% 参数：<AppKey> <ConfigName>
% 用例：./erl_expect -sname ejabberd@ebs-ali-beijing-5 common/get_app_config.erl 'easemob-demo#chatdemoui' use_sub
% easemob-demo#chatdemoui:use_sub@'ejabberd@ebs-ali-beijing-5' = undefined
%
%%%
echo(off),
case Args of
    [AppKey, ConfigName] ->
        io:format("~s:~s@~p = ~p~n", [ AppKey, ConfigName, node(),
                                       app_config:get_app_config(list_to_binary(AppKey),
                                                                 list_to_binary(ConfigName))]);
    _ ->
        io:format("usage: get_app_config.erl <AppKey> <Config>~n",[])
end,
ok.
