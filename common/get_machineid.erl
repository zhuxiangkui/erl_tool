% input: enable | disable
%
% op: enable or disable bypass mode for ejabberd / msync
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/bypass_mode.erl disable

echo(off),

IsEjabberd =
fun() ->
        case lists:keysearch(ejabberd, 1, application:which_applications()) of
            {Value, _} ->
                true;
            _ ->
                false
        end
end,

MachineID = case IsEjabberd() of
    true ->
        ejabberd_ticktick:machine_id();
    false ->
        application:get_env(ticktick, machine_id, 0)
end,

io:format("machine id: ~p~n", [MachineID]),

ok.
