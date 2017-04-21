% input: User
%
% op: delete roster of user
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/delete_roster.erl easemob-demo#chatdemoui_na1

echo(off),
[User] = Args,
LUser = list_to_binary(User),
LServer = <<"easemob.com">>,
mod_roster:remove_user(LUser, LServer).
