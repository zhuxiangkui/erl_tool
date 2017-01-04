echo(on),
[Vsn] = Args,
try  release_handler:install_release(Vsn) of
     {ok, OldVsn1, []} ->
        release_handler:make_permanent(Vsn),
        "GOOD";
     Else ->
        io:format("there are something error happened:~p ~n", [Else]),
        exit(-1)
catch
    Class:Error ->
        io:format("there are something error happened:~p ~n", [{Class, Error}]),
        exit(-1)
end.
