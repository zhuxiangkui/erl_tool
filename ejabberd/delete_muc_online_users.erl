%%%
%% Feature: delete all objects on muc_online_users
%% paras: none
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/delete_muc_online_users.erl
%%
echo(off),
true = ets:delete_all_objects(muc_online_users),
ok.
