echo(off),
case Args of
    ["normal"] ->
        io:format("ok, set auth module to msync_user~n",[]),
        application:set_env(msync, user_auth_module, msync_user);
    ["poolboy"] ->
        io:format("ok, set auth module to msync_user_with_poolboy~n",[]),
        application:set_env(msync, user_auth_module, msync_user_with_poolboy);
    [AnythingElse] ->
        io:format("ok, set to black hole mode~n",[]),
        application:set_env(msync, user_auth_module, blackhole);
    _ ->
        io:format("sorry, I don't know what you mean~n")
end.
