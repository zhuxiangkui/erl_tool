echo(off),
[App, Name, Value] = Args,
application:set_env(list_to_atom(App), list_to_atom(Name), list_to_atom(Value)).
