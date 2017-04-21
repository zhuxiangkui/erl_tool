% input: none
%
% op: delete msg log hook for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/stop_message_log.erl

echo(on),
Host = <<"easemob.com">>,
mod_message_log:del_hook(Host, outgoing_msg),
mod_message_log:del_hook(Host, incoming_msg),
mod_message_log:del_hook(Host, offline_msg),
mod_message_log:del_hook(Host, ack_msg),
mod_message_log:del_hook(Host, setpres),
mod_message_log:del_hook(Host, unsetpres).

