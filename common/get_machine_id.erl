echo(off),
PID = erlang:whereis(ticktick_id),
case sys:get_state(PID) of
  {state, _ ,MachineID, _ , _} ->
    io:format("node ~p  machine_id ~p~n", [node(), MachineID]);
  _ -> not_found
end.
