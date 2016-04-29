echo(off),
case Args of
    [AppKey, ConfigName] ->
        io:format("~s:~s = ~p~n", [ AppKey, ConfigName,
                                    app_config:get_app_config(list_to_binary(AppKey),
                                                              list_to_binary(ConfigName))]);
    [AppKey, ConfigName, ConfigValue ] ->
        io:format("set ~s:~s = ~s  => ~p~n", [ AppKey, ConfigName, ConfigValue,
                                        app_config:set_app_config(list_to_binary(AppKey),
                                                                  list_to_binary(ConfigName),
                                                                  list_to_binary(ConfigValue))]);
    _ ->
        io:format("usage: app_config.erl <AppKey> <Config> [<Value>]~n",[])
end,
ok.
