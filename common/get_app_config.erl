echo(off),
case Args of
    [AppKey, ConfigName] ->
        io:format("~s:~s@~p = ~p~n", [ AppKey, ConfigName, node(),
                                       app_config:get_app_config(list_to_binary(AppKey),
                                                                 list_to_binary(ConfigName))]);
    _ ->
        io:format("usage: get_app_config.erl <AppKey> <Config>~n",[])
end,
ok.
