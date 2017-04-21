% input: none
%
% op: look up the pid of health_monitor
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/health_check_status.erl

echo(on),
whereis(health_monitor).
