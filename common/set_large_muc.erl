
% input: GroupOrChatroom
%
% op: queue group or chatroom message into kafka
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/set_large_muc.erl GroupOrChatroom
% 
%
% GroupOrChatroom: easemob-demo#chatdemoui_1111111

echo(off),
[GroupOrChatroom] = Args,
GroupOrChatroomId = <<(list_to_binary(GroupOrChatroom))/binary,"@conference.easemob.com">>,
io:format("Res:~p~n", [mod_message_limit:set_large_muc(GroupOrChatroomId)]),
ok.
