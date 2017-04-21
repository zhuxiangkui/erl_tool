% input: none
%
% op: stop mod_easemob_sendmsg for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/stop_module_sendmsg.erl

echo(on),
restart_module:stop(mod_easemob_sendmsg),
ok.

