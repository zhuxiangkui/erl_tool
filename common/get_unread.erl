%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/get_unread.erl easemob-demo#chatdemoui_mt001 mobile
%%
echo(off),
[UserIOList, ResourceIOList] = Args,
User = list_to_binary(UserIOList),
Resource = list_to_binary(ResourceIOList),
Unread = easemob_offline_unread:get_unread(<<User/binary, "@easemob.com", Resource/binary>>),
io:format("Unread:~p ~n", [Unread]),
ok.
