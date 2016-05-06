Num = case Args of
	[StrN] ->
	    list_to_integer(StrN);
	_ ->
	    10
    end,

ShowProcess =
fun({Pid, Memory}) ->
	io:format("~p: process memory ~w~n",[os:system_time(milli_seconds), {Pid, Memory, process_info(Pid, [registered_name, initial_call, message_queue_len, current_stacktrace])}])
end,
erlang:memory(),
TopMemProcesses =
lists:sublist(
  lists:usort(
    fun({_,A},{_,B}) -> A > B end,
    lists:map(
      fun(Pid) ->
	      case process_info(Pid, memory) of
		  {memory, Memory} ->
		      {Pid, Memory};
		  _ ->
		      {Pid, 0}
	      end
      end, processes())) , Num),

lists:map(ShowProcess, TopMemProcesses),

io:format("~p: system allocator ~w~n",[os:system_time(milli_seconds),  erlang:system_info(allocator)]),
ok.

