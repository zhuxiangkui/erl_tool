% input: none
%
% op: load message_store config 
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-88 -setcookie secret ejabberd/load_message_store.erl

echo(off),
config:load_env("/data/apps/opt/ejabberd/etc/ejabberd/message_store.config"),
io:format("load config finished ~n",[]).
