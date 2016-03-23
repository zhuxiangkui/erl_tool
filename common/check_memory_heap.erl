
Num = 3,

ShowProcess =
fun({Pid, Memory}) ->
	{Pid, Memory, process_info(Pid, [registered_name, initial_call, message_queue_len, current_stacktrace])}
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

lists:map(ShowProcess, TopMemProcesses).

