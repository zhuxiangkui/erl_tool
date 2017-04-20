% input: EID
%
% op: get resources of user
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-59-pri common/get_resources.erl easemob-demo#chatdemoui_t1@easemob.com
%		"easemob-demo#chatdemoui_t1@easemob.com"'s Resources:[<<"mobile_mobile">>]

echo(off),
[EID] = Args,
Resources = easemob_resource:get_resources(list_to_binary(EID)),
io:format("~p's Resources:~p ~n ", [EID, Resources]).
