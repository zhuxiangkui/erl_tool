echo(off),
io:format("Input Muc Room like easemob-demo#chatdemoui_group1~n Args:~p ~n", [Args]),
[MucArgs] = Args,
Room = <<(list_to_binary(MucArgs))/binary, "@conference.easemob.com">>,
[{_, _, Pid}] = muc_mnesia:rpc_get_online_room(Room),
Node = node(Pid),
MessageQueueLen = rpc:call(Node, erlang, process_info, [Pid, message_queue_len]),
io:format("Muc on Node:~p MessageLength:~p ~n", [Node, MessageQueueLen]).
