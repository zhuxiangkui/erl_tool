%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/restart_dns.erl
%%
echo(on),
inet_config:init(),
inet_gethost_native:control(soft_restart),
ok.
