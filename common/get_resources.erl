%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/get_resources.erl
%%
echo(on),
[EID] = Args,
Resources = easemob_resource:get_resources(EID),
io:format("~p's Resources:~p ~n ", [Resources]).
