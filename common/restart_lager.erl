% input: none
%
% op: restart lager
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/restart_lager.erl

echo(on),
config:load_env("/data/apps/opt/ejabberd/etc/ejabberd/message_store.config"),
application:stop(lager),
application:start(lager),
ok.
