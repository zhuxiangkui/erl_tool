% input: AppKey ConfigName ConfigValue
%
% op: set app_config
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/set_env_atom.erl easemob-demo#chatdemoui roster_only true
%       plz check the gray deploy config :[[app_config,<<"easemob-demo#chatdemoui">>,
%				      	true]]

echo(off),
[App, Name, Value] = Args,
EnvKey = list_to_atom(Name),
case ets:match(app_config, {'$1', {'$2', EnvKey}, '$3'}) of
    [] ->
        application:set_env(list_to_atom(App), EnvKey, list_to_atom(Value));
    AppConfig ->
        io:format("plz check the gray deploy config :~p ~n", [AppConfig])
end.
