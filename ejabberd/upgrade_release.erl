echo(on),
[Vsn] = Args,
release_handler:unpack_release("ejabberd_" ++ Vsn),
{ok, _} = file:copy("/data/apps/opt/ejabberd/etc/ejabberd/" ++ Vsn ++ "/ejabberd.yml",
                    filename:join(["/data/apps/opt/ejabberd/releases", Vsn, "ejabberd.yml"])),
{ok, _} = file:copy("/data/apps/opt/ejabberd/etc/ejabberd/" ++ Vsn ++ "/ejabberd.yml",
                    filename:join(["/data/apps/opt/ejabberd/etc/ejabberd", "ejabberd.yml"])),
{ok, _} = file:copy("/data/apps/opt/ejabberd/etc/ejabberd/ejabberdctl.cfg",
                    filename:join(["/data/apps/opt/ejabberd/releases", Vsn, "ejabberdctl.cfg"])),
{ok, _} = file:copy("/data/apps/opt/ejabberd/etc/ejabberd/" ++ Vsn ++ "/message_store.config",
                    filename:join(["/data/apps/opt/ejabberd/releases", Vsn, "message_store.config"])),
{ok, _} = file:copy("/data/apps/opt/ejabberd/etc/ejabberd/" ++ Vsn ++ "/message_store.config",
                    filename:join(["/data/apps/opt/ejabberd/etc/ejabberd", "message_store.config"])),
{ok, _} = file:copy("/data/apps/opt/ejabberd/etc/ejabberd/inetrc",
                    filename:join(["/data/apps/opt/ejabberd/releases", Vsn, "inetrc"])),

{ok, _} = file:copy("/data/apps/opt/ejabberd/etc/nodetool",
                    filename:join(["/data/apps/opt/ejabberd/releases", Vsn, "nodetool"])),

try
    release_handler:check_install_release(Vsn),
  case release_handler:install_release(Vsn) of
      {ok, OldVsn1, []} ->
          release_handler:make_permanent(Vsn),
          "GOOD";
      Else ->
          Else
  end
catch
    Class:Error -> {Class, Error}
end.
%% ok = release_handler:make_permanent(Vsn).
