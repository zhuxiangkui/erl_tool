% input: none
%
% op: release-16.08.7
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' release/ejabberd_release_16.08.7.erl

echo(off),
config:load_env("/data/apps/opt/ejabberd/etc/ejabberd/message_store.config"),
UpdateModules = [mod_easemob_cache, health_check, msync2xmpp, mod_offline_shared, easemob_apns_mute, app_config, message_store, mod_easemob_api],
lists:foreach(fun(Module) ->
                      code:purge(Module),
                      code:load_file(Module)
              end, UpdateModules),
easemob_redis_pool_sup:connect(apns_mute).
