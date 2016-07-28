% input: Threshold -- integer()
%
% op: LogLevel = critical if lager QueueLength > Threshold(which is input), else LogLevel = info
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/chk_lager_msg_queue_len.erl 10000

echo(off),

[Threshold0] = Args,
Threshold = list_to_integer(Threshold0),

{message_queue_len, QueueLength} = process_info(whereis(lager_event), message_queue_len),

if  QueueLength > Threshold ->
	io:format("error: lager_queue_len = ~p~n", [QueueLength]),
	LogLevel = critical,
	{mask, LogLevel_int} = lager_util:config_to_mask(LogLevel),
	{_, Traces} = lager_config:get(loglevel, {0,[]}),
	lager_config:set(loglevel, {LogLevel_int, Traces});
    true ->
	io:format("info: lager_queue_len = ~p~n", [QueueLength]),
	LogLevel = info,
	{mask, LogLevel_int} = lager_util:config_to_mask(LogLevel),
	{_, Traces} = lager_config:get(loglevel, {0,[]}),
	lager_config:set(loglevel, {LogLevel_int, Traces})
end,
ok.

