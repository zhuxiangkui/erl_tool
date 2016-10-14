echo(off),
[App, Name] = Args,
io:format("~p  ~p~n", [node(), application:get_env(list_to_atom(App), erlang:list_to_atom(Name))]).
