echo(off),
shaper:load_from_config(),
io:format("~p  ~p~n", [node(), ets:tab2list(shaper)]).
