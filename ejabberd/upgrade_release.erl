
%% input: Vsn
%%
%% op: upgrade to release version Vsn
%%
%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/upgrade_release.erl Vsn


echo(off),
case Args of
    [Vsn, DefaultPath] ->
        ok;
    [Vsn] ->
        DefaultPath = "/data/apps/opt"
end,
release_handler:unpack_release("ejabberd_" ++ Vsn),
{ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/ejabberd/ejabberdctl.cfg",
                    filename:join([DefaultPath ++ "/ejabberd/releases", Vsn, "ejabberdctl.cfg"])),
{ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/ejabberd/" ++ Vsn ++ "/sys.config",
                    filename:join([DefaultPath ++ "/ejabberd/releases", Vsn, "sys.config"])),
{Ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/ejabberd/inetrc",
                    filename:join([DefaultPath ++ "/ejabberd/releases", Vsn, "inetrc"])),

{ok, _} = file:copy(DefaultPath ++ "/ejabberd/etc/nodetool",
                    filename:join([DefaultPath ++ "/ejabberd/releases", Vsn, "nodetool"])),

io:format("start to install release~n"),
try
  %release_handler:check_install_release(Vsn, [purge]),
  case release_handler:install_release(Vsn, [{suspend_timeout, infinity}, {code_change_timeout, infinity}]) of
      {ok, OldVsn1, []} ->
          io:format("install release success~n"),
          release_handler:make_permanent(Vsn),
          "GOOD";
      Else ->
          io:format("there are something error happened:~p ~n", [Else]),
          exit(-1)
  end
catch
    Class:Error ->
        io:format("there are something error happened:~p ~n", [{Class, Error}]),
        exit(-1)
end.
