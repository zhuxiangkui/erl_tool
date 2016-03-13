
Num = 3,

TopMemProcesses = 
lists:sublist(
  lists:usort(
    fun({_,A},{_,B}) -> A > B end,
    lists:map(
      fun(Pid) ->
	      {memory, Memory} = process_info(Pid, memory),
	      {Pid, Memory}
      end, processes())) , Num),

ShowProcess = 
fun({Pid, Memory}) ->
	{Pid, Memory, process_info(Pid, [registered_name, initial_call, message_queue_len, current_stacktrace])}
end,       
erlang:memory(),
lists:map(ShowProcess, TopMemProcesses).

