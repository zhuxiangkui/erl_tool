% input: none
%
% op: start lager_monitor (inside message_store_sup)
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/start_lager_monitor.erl

echo(on),

LagerMonitor = {lager_monitor,
                {lager_monitor, start_link, []},
                permanent,
                infinity,
                worker,
                [lager_monitor]
               }.

%% if no such child spec, {error, not_found} is returned and is ignored.
supervisor:terminate_child(message_store_sup, lager_monitor),
supervisor:delete_child(message_store_sup, lager_monitor),

%% do start
supervisor:start_child(message_store_sup, LagerMonitor),
application:set_env(message_store, lager_monitor, true),
ok.
