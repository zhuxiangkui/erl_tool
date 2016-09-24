%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/kick_users.erl
%%
echo(on),

[Pid ! system_shutdown || {_, Pid, _, _} <- supervisor:which_children(whereis('ejabberd_c2s_sup'))],

ok.
