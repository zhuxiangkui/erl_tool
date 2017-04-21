% input: none
%
% op: kill processes of users
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/kick_users.erl

echo(off),

[Pid ! system_shutdown || {_, Pid, _, _} <- supervisor:which_children(whereis('ejabberd_c2s_sup'))],

ok.
