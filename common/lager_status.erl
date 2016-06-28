echo(off),

{Level, Traces} = lager_config:get(loglevel, {0,[]}),
io:format("lager log level is ~p~n", [Level]),
lager:status(),
ok.


