% input: none
%
% op: restart lager
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/restart_lager.erl

echo(on),
application:stop(lager),
application:start(lager),
ok.
