N = case Args of
	[StrN] ->
	    list_to_integer(StrN);
	_ ->
	    10
    end,

BinaryMemory = fun(Bins)  ->
		       lists:foldl(fun({_,Mem,_}, Tot) ->
					   Mem+Tot end, 0, Bins)
	       end,
ProcAttrs = fun(Pid) ->
		    case process_info(Pid, [binary, registered_name,
					    current_function, initial_call]) of
			[{_, Bins}, {registered_name,Name}, Init, Cur] ->
			    {ok, {Pid, BinaryMemory(Bins), [Name || is_atom(Name)]++[Init, Cur]}};
			undefined -> 
			    {error, undefined}
		    end
	    end,

MostBinarySize = fun(N) ->
			 List = [
				 try
				     erlang:garbage_collect(Pid),
				     {ok, { _, Value, Props } } = ProcAttrs(Pid),
				     {Pid, Value, Props}
				 catch 
				     _:_ -> {Pid, 0, []}
				 end
				 || Pid <- processes()
				],
			 List2 = 
			     lists:usort(
			       fun({K1,V1,_},{K2,V2,_}) ->
				       {V1,K1} >= {V2,K2} 
			       end, List
			       
			      ),
			 Sum = lists:foldl(fun({_,V,_}, S) -> S + V end, 0, List2),
			 io:format("total binary = ~p Mb; top~n", [Sum/1024/1024]),
			 lists:foreach(
			   fun({Pid,Size,Info}) ->
				   io:format("Pid = ~p, Size = ~p Mb, Info = ~p~n", [Pid, Size/1024/1024, Info])
			   end,lists:sublist(List2,N))
		 end,

MostBinarySize(N),
ok.
