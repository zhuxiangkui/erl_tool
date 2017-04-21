% input: none
%
% op: get polling_offline_time
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/get_polling_offline_time.erl

echo(off),

Time = ejabberd_config:get_option(polling_offline_time, fun(A) -> A end, 0),
io:format("polling_offline_time is ~p~n", [Time]).
