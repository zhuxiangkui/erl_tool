% input: none
%
% op: enable heartbeat pushing offline msg for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/enable_polling_offline.erl

echo(off),

ets:insert(local_config, {local_config, {polling_offline, global}, true}),

case ejabberd_config:get_option(polling_offline, fun(A) -> A end, false) of
    true ->
        io:format("polling_offline is enabled~n");
    false ->
        io:format("polling_offline is disabled~n")
end.
