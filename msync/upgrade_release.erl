echo(on),
[Vsn] = Args,
release_handler:unpack_release("msync_" ++ Vsn),
{ok, _} = file:copy("/data/apps/opt/msync/etc/app.config." ++ Vsn,
                    filename:join(["/data/apps/opt/msync/releases", Vsn, "sys.config"])),

{ok, _} = file:copy("/data/apps/opt/msync/etc/nodetool",
                    filename:join(["/data/apps/opt/msync/releases", Vsn, "nodetool"])),

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
