
lists:foreach(
  fun(N) ->
          timer:sleep(1000),
          io:format("sending ~p from ~p~n", [N, self()]),
          erlang:send(x,N)
  end, lists:seq(1,600)).
