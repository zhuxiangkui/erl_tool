% input: none
%
% op: start erl_om
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/start_erl_om.erl

code:add_path("/data/apps/opt/ejabberd/lib/erl_om-0.1/ebin"),
config:load_env("/data/apps/opt/ejabberd/etc/ejabberd/message_store.config"),
erl_om:stop(),
erl_om:start().
