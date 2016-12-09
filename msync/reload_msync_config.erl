%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/reload_msync_config.erl
%%
echo(on),
echo(off),
{value, {_, _, Vsn}} = lists:keysearch(msync, 1, application:which_applications()),
ConfigFile = "/data/apps/opt/msync/releases/" ++ Vsn ++ "/sys.config",
config:load_env(ConfigFile),
io:format("load config finished ~n",[]).
