% input: none
%
% op: restart muc for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/restart_muc.erl

echo(on),
restart_module:stop(mod_easemob_cache),
restart_module:start(mod_easemob_cache),
easemob_redis_pool_sup:disconnect(muc),
easemob_redis_pool_sup:connect(muc),
ok.
