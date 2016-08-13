echo(on),
[Vsn] = Args,
try  release_handler:install_release(Vsn) of
     {ok, OldVsn1, []} ->
        release_handler:make_permanent(Vsn),
        "GOOD";
     Else ->
        Else
catch
    Class:Error -> {Class, Error}
end.
%% ok = release_handler:make_permanent(Vsn).
