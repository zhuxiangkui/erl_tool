% input: AppKey KeyType | AppKey KeyType ConfigValue
%
% op: look up or set encrypt_key
%
% e.g.: 
%set private/public key
%      1 choose a Target ejabberd node
%      2 copy key_file(private.pem/public.pem) to /data/apps/opt/ejabberd/ on the node which is choosed
%      3 ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/encrypt_key.erl easemob-demo#chatdemoui public_key
%set symmetrical key
%      1 ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/encrypt_key.erl easemob-demo#chatdemoui symmetrical_key easemob##easemob

echo(off),

case Args of
    [AppKey, "public_key"] ->
	{ok, KeyBin} = file:read_file("/data/apps/opt/ejabberd/public.pem"),
	io:format("set ~s:public_key = ~s  => ~p~n", [AppKey, KeyBin,
				    easemob_encrypt:set_public_key(list_to_binary(AppKey),
								   KeyBin)]);       
    [AppKey, "private_key"] ->
	{ok, KeyBin} = file:read_file("/data/apps/opt/ejabberd/private.pem"),
	io:format("set ~s:private_key = ~s  => ~p~n", [AppKey, KeyBin,
				    easemob_encrypt:set_private_key(list_to_binary(AppKey),
								    KeyBin)]);							  
    [AppKey, "symmetrical_key", ConfigValue] ->
	io:format("set ~s:symmetrical_key = ~s  => ~p~n", [AppKey, ConfigValue,
				    easemob_encrypt:set_symmetrical_key(list_to_binary(AppKey),
									list_to_binary(ConfigValue))]);
     _ ->
	io:format("Error format, Pls input <AppKey> <KeyType> [<ConfigValue>] ~n", [])
end,
ok.
