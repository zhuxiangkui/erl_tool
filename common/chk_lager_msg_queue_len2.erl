% input: Threshold -- integer()
%
% op: LogLevel = critical if lager QueueLength > Threshold(which is input), else do nothing
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/chk_lager_msg_queue_len2.erl 10000

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
	{Level, _Traces} = lager_config:get(loglevel, {0,[]}),
	case Level == 127 of
	    false ->
		io:format("error: log level = ~p~n", [Level]);
	    true ->
		io:format("info: log level = ~p, queue len = ~p~n", [Level, QueueLength])
	end
end,
ok.

