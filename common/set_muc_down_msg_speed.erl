% input: MUCId MemberNum1 DownSpeed1 MemberNum2 DownSpeed2 ...
%
% op: set chatroom down message speed, if down message speed great than this speed , low priority message will maybe be droped.
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/set_muc_down_msg_speed.erl MUCId MemberNum1 DownSpeed1 MemberNum2 DownSpeed2 ...
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/set_muc_down_msg_speed.erl easemob-demo#chatdemoui_1111111 0 1000 1000 30 3000 10

echo(off),
[MUCId|Rules]=Args,
{none,Rule} = 
    lists:foldl(
         fun(E,{none, Acc}) ->
                 {list_to_integer(E), Acc};
            (E, {Last, Acc}) ->
                 {none, Acc++[{Last, list_to_integer(E)}]}
         end,{none,[]}, Rules),
mod_message_limit:set_muc_down_speed(
  list_to_binary(MUCId), 
  Rule),

ok.
