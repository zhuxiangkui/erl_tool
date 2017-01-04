echo(on),
case Args of
    [Vsn, DefaultPath] ->
        ok;
    [Vsn] ->
        DefaultPath = "/data/apps/opt"
end,

try
    release_handler:check_install_release(Vsn),
  case release_handler:install_release(Vsn) of
      {ok, OldVsn1, []} ->
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
