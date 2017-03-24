%% input: MUCId 
%%
%% op: unset chatroom down message speed

%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/unset_muc_down_msg_speed.erl MUCId
%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/unset_muc_down_msg_speed.erl easemob-demo#chatdemoui_1111111

echo(off),
[MUCId]=Args,
mod_message_limit:unset_muc_down_speed(
  list_to_binary(MUCId)
),

ok.
