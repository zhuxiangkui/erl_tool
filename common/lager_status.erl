% input: none
%
% op: check lager status
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/lager_status.erl
%		lager log level is 127
%		lager_queue_len = 0

echo(off),

{Level, Traces} = lager_config:get(loglevel, {0,[]}),
io:format("lager log level is ~p~n", [Level]),
{message_queue_len, QueueLength} = process_info(whereis(lager_event), message_queue_len),
io:format("lager_queue_len = ~p~n", [QueueLength]),
%% lager:status(),
ok.


