N = case Args of
	[StrN] ->
	    list_to_integer(StrN);
	_ ->
	    10
    end,
ShowQueueInfo = 
fun ({_Pid, {message_queue_len, 0} }) ->
	ok;
    ({Pid, {message_queue_len, N} }) ->
	io:format("process ~p: queue length ~p ~n", [Pid, N])
end,

SysInfo1 = 
fun (Id) ->
	io:format("LIMIT ~p = ~p~n", [Id, erlang:system_info(Id)])
end,


SysInfo = 
fun() ->
	Infos = [
		 process_count,
		 process_limit,
		 port_count,
		 port_limit,
		 build_type
		],
	lists:foreach(SysInfo1, Infos),
	lists:foreach(
	  fun ({Type, Size}) ->
		  io:format("MEM ~p = ~p M~n",[Type,Size / 1024 / 1024])
	  end,
	  erlang:memory()
	 )
end,
MQInfoMessage = 
fun ({system,{Pid, _Ref}, get_state} ) ->
	io:format("How dare ~p  call sys:get_state~n", [Pid]),
	io:format("Caller  ~p CALL_STACK: ~p ~n",
		  [Pid, erlang:process_info(Pid, current_stacktrace)]);
    (M) ->
	io:format("MESSAGE_IN_PID  ~p~n", [M])
end,

MQInfo = 
fun (Pid) ->
	SysInfo(),
	case erlang:process_info(Pid, message_queue_len) of
	    {message_queue_len, QueueLength } ->
		io:format("MAXQUEUELEN  ~p PID ~p ~n",
			  [QueueLength, Pid]),
		io:format("MESSAGE_INITIAL_CALL  ~p ~p~n",
			  [Pid, proc_lib:translate_initial_call(Pid)]),
		io:format("CALL_STACK  ~p : ~p ~n",
			  [Pid, erlang:process_info(Pid, current_stacktrace)]),
		io:format("MEMORY  ~p  ~p ~n",
			  [Pid, erlang:element(2,erlang:process_info(Pid, memory))]),
		io:format("STATUS  ~p  ~p ~n",
			  [Pid, erlang:element(2,erlang:process_info(Pid, status))]),
		{messages, L} = erlang:process_info(Pid, messages),
		lists:foreach(
		  MQInfoMessage,
		  lists:sublist(L, 20));
	    _ ->
		io:format("process_info Pid ~p return undefined, ~p is probably died.~n", [Pid, Pid])
	end
end,


LongestMQ = 
fun() ->
	L = lists:reverse( lists:keysort(2, [ {P, erlang:process_info(P, message_queue_len) } || P <- erlang:processes() ] )),
	lists:foreach(ShowQueueInfo, lists:sublist(L, N)),
	[{Pid,_} | _ ] = L,
	MQInfo(Pid)
end,

%%% 


LongestMQ(),

ok.
