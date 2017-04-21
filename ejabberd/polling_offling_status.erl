% input: none
%
% op: show the current status of whether polling offline is enabled or not
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/enable_polling_offline.erl

echo(off),

case ejabberd_config:get_option(polling_offline, fun(A) -> A end, false) of
    true ->
        io:format("polling_offline is enabled~n");
    false ->
        io:format("polling_offline is disabled~n")
end.
