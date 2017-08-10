%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/set_platform_res_len.erl easemob-demo#chatdemoui res:len:webim 3
%%
echo(off),
[AppKeyBin, PlatFormLenBin, NumBin] = Args,
AppKey = list_to_binary(AppKeyBin),
ConfigName = list_to_binary(PlatFormLenBin),
ConfigValue = list_to_atom(NumBin),
app_config:set_app_config_global(AppKey, ConfigName, ConfigValue),
app_config:set_app_config(AppKey, ConfigName, ConfigValue),
ok.
