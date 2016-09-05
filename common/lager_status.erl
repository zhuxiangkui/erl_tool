
% input: none
%
% op: check lager status
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/lager_status.erl

echo(off),

{Level, Traces} = lager_config:get(loglevel, {0,[]}),
io:format("lager log level is ~p~n", [Level]),
{message_queue_len, QueueLength} = process_info(whereis(lager_event), message_queue_len),
io:format("lager_queue_len = ~p~n", [QueueLength]),
%% lager:status(),
ok.


