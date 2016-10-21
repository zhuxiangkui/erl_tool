echo(off),
MachineID = ejabberd_ticktick:machine_id(),
Node = node(),
[_, Num, _] = binary:split(erlang:list_to_binary(erlang:atom_to_list(Node)), [<<"beijing-">>, <<"-pri">>], [global]),
MustNum = erlang:binary_to_integer(Num),
case MustNum + 100 == MachineID of
true  ->
ignore;
    false ->
io:format("MachineID:~p ~n", [MachineID])
end.
