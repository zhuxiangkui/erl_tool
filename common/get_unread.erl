% input: UserIOList ResourceIOList
%
% op: get offline msgs of users 
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/get_unread.erl easemob-demo#chatdemoui_na4 moblie
%		Unread:[]

echo(off),
[UserIOList, ResourceIOList] = Args,
User = list_to_binary(UserIOList),
Resource = list_to_binary(ResourceIOList),
Unread = easemob_offline_unread:get_unread(<<User/binary, "@easemob.com/", Resource/binary>>),
io:format("Unread:~p ~n", [Unread]),
ok.
