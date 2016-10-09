
% input: none
%
% op: restart ekaf
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/restart_ekaf.erl

echo(on),
easemob_message_log:stop(),
easemob_message_log:start(),
ok.
