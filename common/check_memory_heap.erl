% input: Num
%
% op: check memory heap
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd' common/check_memory_heap.erl 1
%       [{1492600803441, {<8226.684.0>,284640,
%                  [{registered_name,health_monitor},
%       ...

Num = case Args of
	[StrN] ->
	    list_to_integer(StrN);
	_ ->
	    10
    end,

ShowProcess =
fun({Pid, Memory}) ->
	io:format("[{~p, ~p},~n",[os:system_time(milli_seconds), {Pid, Memory, process_info(Pid, [registered_name, initial_call, message_queue_len, current_stacktrace])}])
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

io:format("{~p, ~p}]~n",[os:system_time(milli_seconds),  erlang:system_info(allocator)]),
ok.

