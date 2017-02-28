echo(on),
case Args of
    [Vsn, DefaultPath] ->
        ok;
    [Vsn] ->
        DefaultPath = "/data/apps/opt"
end,

io:format("Args: ~p~n", [Args]),
try
  case release_handler:install_release(Vsn, [{suspend_timeout, infinity}, {code_change_timeout, infinity}]) of
      {ok, OldVsn1, []} ->
          release_handler:make_permanent(Vsn),
          io:format("make permanent success"),
          release_handler:remove_release(OldVsn1),
          io:format("remove release success"),
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
