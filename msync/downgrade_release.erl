echo(on),
[Vsn] = Args,

io:format("Args:~p ~n", [Args]),
try  release_handler:install_release(Vsn) of
     {ok, OldVsn1, []} ->
        release_handler:make_permanent(Vsn),
        release_handler:remove_release(OldVsn1),
        "GOOD";
     Else ->
        io:format("there are something error happened:~p ~n", [Else]),
        exit(-1)
catch
    Class:Error ->
        io:format("exception:~p ~n", [{Class, Error}]),
        exit(-1)
end.
