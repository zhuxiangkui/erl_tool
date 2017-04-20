% input: none
%
% op: stop ekaf
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/stop_ekaf.erl

echo(on),
application:stop(ekaf).
