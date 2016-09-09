% input: none
%
% op: reopne apns mute
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' release/ejabberd_open_apns_mute.erl

echo(off),
{ok, _} = config:load_env("/data/apps/opt/ejabberd/etc/ejabberd/message_store.config"),
easemob_redis_pool_sup:connect(apns_mute).
