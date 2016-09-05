echo(on),
[Vsn] = Args,
try  release_handler:remove_release(Vsn) of
     ok ->
        "GOOD";
     Else ->
        Else
catch
    Class:Error -> {Class, Error}
end.
