% input: none
%
% op: restart roster for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/restart_roster.erl

echo(on),
restart_module:stop(mod_roster),
restart_module:start(mod_roster),
ok.
