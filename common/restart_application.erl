echo(off),
[App] = Args,
application:stop(list_to_atom(App)),
Ret = application:ensure_all_started(list_to_atom(App)),
io:format("~p  ~p~n", [node(), Ret]).
