echo(off),

case Args of
    [Prefix, AppName, Key, Value] ->
        io:format("~p~n", [etcdc:set(filename:join([Prefix, AppName, Key]), Value)]);
    _ ->
        io:format("~p~n", [{error, args_error}])
end,
ok.