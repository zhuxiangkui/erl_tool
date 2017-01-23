echo(on),
case Args of
    [Vsn, DefaultPath] ->
        ok;
    [Vsn] ->
        DefaultPath = "/data/apps/opt"
end,

io:format("Args: ~p~n", [Args]),
try
  case release_handler:install_release(Vsn) of
      {ok, OldVsn1, []} ->
          release_handler:make_permanent(Vsn),
          release_handler:remove_release(OldVsn1),
          "GOOD";
      Else ->
          io:format("there are something error happened:~p ~n", [Else]),
          exit(-1)
  end
catch
    Class:Error ->
        io:format("exception:~p ~n", [{Class, Error}]),
        exit(-1)
end.
