% input: none
%
% op: reload config of ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/reload_ejabberd_config.erl

echo(off),
{value, {_, _, Vsn}} = lists:keysearch(ejabberd, 1, application:which_applications()),
{ok, _} = file:copy("/data/apps/opt/ejabberd/etc/ejabberd/" ++ Vsn ++ "/sys.config",
                    filename:join(["/data/apps/opt/ejabberd/etc/ejabberd", "sys.config"])),
ConfigFile = "/data/apps/opt/ejabberd/releases/" ++ Vsn ++ "/sys.config",
config:load_env(ConfigFile),
ejabberd_config:load_file(ConfigFile),
io:format("load config finished ~n",[]).
