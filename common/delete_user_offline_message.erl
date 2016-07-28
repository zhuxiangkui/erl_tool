% input: JID
%
% op: delete JID all offline msg
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/delete_user_offline_message.erl easemob-demo#chatdemoui_mt001

echo(off),
[JID] = Args,
ExpireTime = easemob_resource:get_resource_expire_time(),
message_store:delete_user(iolist_to_binary([JID, "@easemob.com"]), <<"">>,ExpireTime),
ok.
