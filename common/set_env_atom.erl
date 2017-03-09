echo(off),
[App, Name, Value] = Args,
EnvKey = list_to_atom(Name),
case ets:match(app_config, {'$1', {'$2', EnvKey}, '$3'}) of
    [] ->
        application:set_env(list_to_atom(App), EnvKey, list_to_atom(Value));
    AppConfig ->
        io:format("plz check the gray deploy config :~p ~n", [AppConfig])
end.
