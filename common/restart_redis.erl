echo(on),

Restart = fun(mod_easemob_cache) ->
                  restart_module:restart(mod_easemob_cache);
             (mod_roster_cache) ->
                  restart_module:restart(mod_roster_cache);
             (Name) ->
                  easemob_redis_pool_sup:disconnect(Name),
                  easemob_redis_pool_sup:connect(Name)
          end,
Restart(list_to_atom(lists:nth(1,Args))),
ok.

