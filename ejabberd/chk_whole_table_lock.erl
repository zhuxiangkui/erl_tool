%% ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri ejabberd/chk_whole_table_lock.erl $(cat /data/shell/ejabberlist.txt |grep -v '#' | sed 's/.*/\0-pri/g')


Nodes = lists:map(fun(Host) -> list_to_atom("ejabberd@" ++ Host) end,
		  Args),
AllNodes = [node() | nodes()],

ActiveNodes = AllNodes -- (Nodes -- AllNodes),

case Nodes -- ActiveNodes of
    [] ->
	ok;
    DeadNodes ->
	io:format("ERROR: dead nodes ~p~n",[DeadNodes])
end,

IsWholeTableLock =
fun
({{schema,'______WHOLETABLE_____'}, _, _})  ->
    true;
(_) ->
    false
end,
GetHoldLock =
fun (Node) ->
	rpc:call(Node, mnesia,system_info, [held_locks])
	%% [{{schema,'______WHOLETABLE_____'},write,{tid, 105072102, 1}}]
end,

GetHoldLock(node),

lists:foreach(
  fun(Node) ->
	  case GetHoldLock(Node) of
	      Locks when is_list(Locks) ->
		  case lists:filter(IsWholeTableLock, Locks) of
		      [] ->
			  ok;
		      _ ->
			  io:format("ERROR: ~p WHOLETABLE lock ~p~n", [Node, Locks])
		  end;
	      OtherWise ->
		  io:format("ERROR: ~p held locks ~p~n", [Node, OtherWise])
	  end
  end,
  ActiveNodes).

