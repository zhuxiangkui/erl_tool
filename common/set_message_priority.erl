
% input: AppKey MsgLevelType Priority
%
% op: set message priority 
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/set_message_priority.erl easemob-demo#chatdemoui member_msg low 
% 
%
% MsgLevelType: anchor_msg, admin_msg, member_msg, thumb_msg, multimedia_msg, gift_msg, custom1_msg, custom2_msg, custom3_msg, custom4_msg
% Priority: normal or low

echo(off),
[AppKey0, MsgLevelType0, Priority0] = Args,
AppKey = list_to_binary(AppKey0),
MsgLevelType = list_to_binary(MsgLevelType0),
Priority = list_to_binary(Priority0),
io:format("Res:~p~n", [mod_message_limit:set_message_priority(AppKey, MsgLevelType, Priority)]),
ok.
