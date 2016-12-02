%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/restart_thrift_service.erl
%%
echo(off),
ejabberd_app:stop_thrift_service(),
ejabberd_app:start_thrift_service(),
ok.
