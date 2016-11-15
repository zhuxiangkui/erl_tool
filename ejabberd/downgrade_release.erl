echo(on),
case Args of
    [Vsn, DefaultPath] ->
        ok;
    [Vsn] ->
        DefaultPath = "/data/apps/opt"
end,

{ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/ejabberd/" ++ Vsn ++ "/ejabberd.yml",
                    filename:join([DefaultPath ++ "/ejabberd/etc/ejabberd", "ejabberd.yml"])),

{ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/ejabberd/" ++ Vsn ++ "/message_store.config",
                    filename:join([DefaultPath ++ "/ejabberd/etc/ejabberd", "message_store.config"])),
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
