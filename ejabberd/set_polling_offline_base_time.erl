% input: Time
%
% op: set polling_offline_base_time
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/set_polling_offline_base_time.erl 300001
%		polling_offline_base_time is 300001

echo(off),

[Time0] = Args,
Time = list_to_integer(Time0),
case Time >= 300000 of
    true ->
        ets:insert(local_config, {local_config, {polling_offline_base_time, global}, Time}),
        Int = ejabberd_config:get_option(polling_offline_base_time, fun(A) -> A end, 0),
        io:format("polling_offline_base_time is ~p~n", [Int]);
    false ->
        io:format("[error] could not set polling_offline_base_time of value smaller than 5 minite~n")
end.
