%%%
%% Feature:
%% paras: 时间为毫秒（ms）
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/set_res_expire_time.erl webim 100
%%
echo(off),
[ResourceIOList, ExpireTimeIOList] = Args,
Resource = list_to_binary(ResourceIOList),
ExpireTime = list_to_integer(ExpireTimeIOList),
io:format("Before Setting:~p ~n", [easemob_resource:get_resource_expire_time()]),
easemob_resource:set_resource_expire_time(Resource, ExpireTime),
io:format("After Setting:~p ~n", [easemob_resource:get_resource_expire_time()]).
