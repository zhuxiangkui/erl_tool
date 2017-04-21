% input: none
%
% op: load muc min message interval
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd' ejabberd/load_mod_muc_min_message_internal.erl
% 		MinMessageInternal:0.2

echo(off),
Module = mod_muc,
Host = <<"easemob.com">>,
Opts = ejabberd_config:get_option({modules,global},fun(Mods) -> proplists:get_value(Module, Mods) end, []),
ets:insert(ejabberd_modules, {ejabberd_module, {Module, Host}, Opts}),
MinMessageInternal = gen_mod:get_module_opt(<<"easemob.com">>, mod_muc, min_message_interval, fun(MMI) when is_number(MMI) -> MMI end, 0),
io:format("MinMessageInternal:~p ~n", [MinMessageInternal]),
ok.
