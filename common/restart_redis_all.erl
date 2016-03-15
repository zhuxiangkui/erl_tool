
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
