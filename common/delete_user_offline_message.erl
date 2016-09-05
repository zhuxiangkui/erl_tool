echo(off),
ExpireTime = easemob_resource:get_resource_expire_time(),
case Args of
  [JID] ->
    message_store:delete_user(iolist_to_binary([JID, "@easemob.com"]), <<"">>, ExpireTime);
  [JID, Res] ->
    message_store:delete_user(iolist_to_binary([JID, "@easemob.com"]), list_to_binary(Res), ExpireTime)
end,
ok.
