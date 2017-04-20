% input: none
%
% op: restart all redis
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/restart_redis_all.erl

Restart = fun(Name) ->
                  easemob_redis_pool_sup:disconnect(Name),
                  easemob_redis_pool_sup:connect(Name)
          end,
Restart(index),
Restart(body),
Restart(roster),
Restart(log),
Restart(muc),
Restart(privacy),
Restart(resource),
Restart(group_msg).
