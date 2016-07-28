
% input: none
%
% op: add msg log hook for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/start_message_log.erl

echo(on),
Host = <<"easemob.com">>,
mod_message_log:add_hook(Host, outgoing_msg),
mod_message_log:add_hook(Host, incoming_msg),
mod_message_log:add_hook(Host, offline_msg),
mod_message_log:add_hook(Host, ack_msg),
mod_message_log:add_hook(Host, setpres),
mod_message_log:add_hook(Host, unsetpres).

