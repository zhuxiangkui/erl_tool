% input: none
%
% op: restart odbc for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/restart_roster_odbc.erl

echo(on),
easemob_odbc_sup:stop(),
easemob_odbc_sup:start().
