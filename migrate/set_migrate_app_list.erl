echo(on),

application:set_env(migrate_offline, appkey_list,
                    lists:map(fun(X) -> erlang:list_to_binary(X) end, Args)),
ok.
