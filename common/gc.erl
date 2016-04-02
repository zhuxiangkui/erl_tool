lists:foreach(
  fun(Pid) ->
	  catch erlang:garbage_collect(Pid)
  end, erlang:processes()),
ok.
