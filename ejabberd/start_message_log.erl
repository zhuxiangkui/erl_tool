echo(on),
Host = <<"easemob.com">>,
mod_message_log:add_hook(Host, outgoing_msg),
mod_message_log:add_hook(Host, incoming_msg),
mod_message_log:add_hook(Host, offline_msg),
mod_message_log:add_hook(Host, ack_msg),
mod_message_log:add_hook(Host, setpres),
mod_message_log:add_hook(Host, unsetpres).

