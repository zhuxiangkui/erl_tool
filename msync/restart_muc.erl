% input: none
%
% op: restart muc for msync
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/restart_muc.erl

echo(on),
easemob_redis_pool_sup:disconnect(muc),
easemob_redis_pool_sup:connect(muc),
ok.
