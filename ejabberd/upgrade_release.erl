echo(on),
case Args of
    [Vsn, DefaultPath] ->
        ok;
    [Vsn] ->
        DefaultPath = "/data/apps/opt"
end,
release_handler:unpack_release("ejabberd_" ++ Vsn),
{ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/ejabberd/" ++ Vsn ++ "/ejabberd.yml",
                    filename:join([DefaultPath ++ "/ejabberd/releases", Vsn, "ejabberd.yml"])),
{ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/ejabberd/" ++ Vsn ++ "/ejabberd.yml",
                    filename:join([DefaultPath ++ "/ejabberd/etc/ejabberd", "ejabberd.yml"])),
{ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/ejabberd/ejabberdctl.cfg",
                    filename:join([DefaultPath ++ "/ejabberd/releases", Vsn, "ejabberdctl.cfg"])),
{ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/ejabberd/" ++ Vsn ++ "/message_store.config",
                    filename:join([DefaultPath ++ "/ejabberd/releases", Vsn, "message_store.config"])),
file:copy(DefaultPath ++ "/ejabberd/etc/ejabberd/" ++ Vsn ++ "/sys.config",
                    filename:join([DefaultPath ++ "/ejabberd/releases", Vsn, "sys.config"])),
{ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/ejabberd/" ++ Vsn ++ "/message_store.config",
                    filename:join([DefaultPath ++ "/ejabberd/etc/ejabberd", "message_store.config"])),
{Ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/ejabberd/inetrc",
                    filename:join([DefaultPath ++ "/ejabberd/releases", Vsn, "inetrc"])),

{ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/nodetool",
                    filename:join([DefaultPath ++ "/ejabberd/releases", Vsn, "nodetool"])),

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
