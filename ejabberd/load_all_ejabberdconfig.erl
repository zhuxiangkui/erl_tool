% input: none
%
% op: load all config 
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-88 -setcookie secret ejabberd/load_all_ejabberdconfig.erl

echo(off),
ejabberd_config:load_file("/data/apps/opt/ejabberd/etc/ejabberd/ejabberd.yml"),
config:load_env("/data/apps/opt/ejabberd/etc/ejabberd/message_store.config"),
io:format("load config finished ~n",[]).
