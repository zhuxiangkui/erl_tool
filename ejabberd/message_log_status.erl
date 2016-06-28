echo(on),
application:ensure_all_started(ekaf),
Host = <<"easemob.com">>,
mod_message_log:is_hook_ready(Host, outgoing_msg),
mod_message_log:is_hook_ready(Host, incoming_msg),
mod_message_log:is_hook_ready(Host, offline_msg),
mod_message_log:is_hook_ready(Host, ack_msg),
mod_message_log:is_hook_ready(Host, setpres),
mod_message_log:is_hook_ready(Host, unsetpres).

