% input: none
%
% op: get machine id
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/get_machine_id.erl
%       node 'ejabberd@ejabberd-worker'  machine_id 159

echo(off),
PID = erlang:whereis(ticktick_id),
case sys:get_state(PID) of
  {state, _ ,MachineID, _ , _} ->
    io:format("node ~p  machine_id ~p~n", [node(), MachineID]);
  _ -> not_found
end.
