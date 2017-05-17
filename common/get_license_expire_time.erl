%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/get_license_expire_time.erl
%%
echo(off),
ExpireTime = ejabberd_license:get_expire_date(),
io:format("The Server's expire time is :~p ~n", [ExpireTime]),
ok.
