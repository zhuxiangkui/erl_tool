echo(off),
PID = erlang:whereis(ticktick_id),
case sys:get_state(PID) of
  {state, _ ,MachineID, _ , _} ->
    io:format("machine_id ~p~n", [MachineID]);
  _ -> not_found
end.
