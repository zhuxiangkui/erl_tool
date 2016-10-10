echo(on),
[Vsn] = Args,

{ok, _} = file:copy("/data/apps/opt/ejabberd/etc/ejabberd/" ++ Vsn ++ "/ejabberd.yml",
                    filename:join(["/data/apps/opt/ejabberd/etc/ejabberd", "ejabberd.yml"])),

{ok, _} = file:copy("/data/apps/opt/ejabberd/etc/ejabberd/" ++ Vsn ++ "/message_store.config",
                    filename:join(["/data/apps/opt/ejabberd/etc/ejabberd", "message_store.config"])),
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
