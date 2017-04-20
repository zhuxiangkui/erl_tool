% input: none
%
% op: start ekaf
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/start_ekaf.erl

echo(on),
application:ensure_all_started(ekaf).
