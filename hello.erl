A = io:format("hello world from ~p~n",[node()]),
B = io:format("Hi ~p~n",[node()]),
lists:foreach(
  fun(X) ->
          io:format("hello ~p~n",[X])
  end, Args).
