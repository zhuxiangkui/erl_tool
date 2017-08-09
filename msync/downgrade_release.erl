echo(on),
[Vsn] = Args,

io:format("Args:~p ~n", [Args]),
[{_,OldVsn,_,_}]=release_handler:which_releases(permanent),
try  release_handler:install_release(Vsn, [{suspend_timeout, infinity}, {code_change_timeout, infinity}]) of
     {ok, _OtherVsn, []} ->
        release_handler:make_permanent(Vsn),
        io:format("make permanent success"),
        release_handler:remove_release(OldVsn),
        io:format("remove release success"),
        "GOOD";
     Else ->
        io:format("there are something error happened:~p ~n", [Else]),
        exit(-1)
catch
    Class:Error ->
        io:format("exception:~p ~n", [{Class, Error}]),
        exit(-1)
end.
