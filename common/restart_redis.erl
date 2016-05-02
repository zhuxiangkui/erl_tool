echo(on),

Restart = fun(Name) ->
                  easemob_redis_pool_sup:disconnect(Name),
                  easemob_redis_pool_sup:connect(Name)
          end,
Restart(list_to_atom(lists:nth(1,Args))),
ok.

