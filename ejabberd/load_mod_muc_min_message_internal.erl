%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/load_mod_muc_min_message_internal.erl
%%
echo(on),
[Vsn] = Args,
{ok, _} = file:copy("/data/apps/opt/ejabberd/etc/ejabberd/" ++ Vsn ++ "/ejabberd.yml",
                    filename:join(["/data/apps/opt/ejabberd/releases", Vsn, "ejabberd.yml"])),
{ok, _} = file:copy("/data/apps/opt/ejabberd/etc/ejabberd/" ++ Vsn ++ "/ejabberd.yml",
                    filename:join(["/data/apps/opt/ejabberd/etc/ejabberd", "ejabberd.yml"])),
ejabberd_config:load_file("/data/apps/opt/ejabberd/etc/ejabberd/ejabberd.yml"),
Module = mod_muc,
Host = <<"easemob.com">>,
Opts = ejabberd_config:get_option({modules,global},fun(Mods) -> proplists:get_value(Module, Mods) end, []),
ets:insert(ejabberd_modules, {ejabberd_module, {Module, Host}, Opts}),
MinMessageInternal = gen_mod:get_module_opt(<<"easemob.com">>, mod_muc, min_message_interval, fun(MMI) when is_number(MMI) -> MMI end, 0),
io:format("MinMessageInternal:~p ~n", [MinMessageInternal]),
ok.
