echo(off),
[JID] = Args,
ExpireTime = easemob_resource:get_resource_expire_time(),
message_store:delete_user(iolist_to_binary([JID, "@easemob.com"]), <<"">>,ExpireTime),
ok.
