% input: Time
%
% op: set polling_offline_time
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/set_polling_offline_time.erl

echo(off),

[Time0] = Args,
Time = list_to_integer(Time0),

ets:insert(local_config, {local_config, {polling_offline_time, global}, Time}),

Int = ejabberd_config:get_option(polling_offline_time, fun(A) -> A end, 0),
io:format("polling_offline_time is ~p~n", [Int]).
