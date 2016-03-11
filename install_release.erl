[Name, Vsn] = Args,
{ok, _} = file:copy(filename:join(["/data/apps/opt/msync", "msync_" ++ Vsn ++ ".tar.gz"]),
                    "/data/apps/opt/msync/releases"),
release_handler:unpack_release(Name ++ "_" ++ Vsn),
{ok, _} = file:copy("/data/apps/opt/msync/etc/app.config.org",
                    filename:join(["/data/apps/opt/msync/releases", Vsn, "sys.config"])),
{ok, OldVsn} = release_handler:install_release(Name ++ "_" ++ Vsn),
{ok, OldVsn} = release_handler:make_permanent(Name ++ "_" ++ Vsn).
