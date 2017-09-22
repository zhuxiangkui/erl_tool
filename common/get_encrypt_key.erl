% input: AppKey KeyType | AppKey KeyType ConfigValue
%
% op: look up or set encrypt_key
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/encrypt_key.erl easemob-demo#chatdemoui public_key
%            easemob-demo#chatdemoui: private key = undefined

echo(off),

case Args of
    [AppKey, "public_key"] ->
	io:format("~s: public key = ~p~n", [AppKey,
				    easemob_encrypt:get_rsa_public_key_original(list_to_binary(AppKey))]);
    [AppKey, "private_key"] ->
	io:format("~s: private key = ~p~n", [AppKey,
				    easemob_encrypt:get_rsa_private_key_original(list_to_binary(AppKey))]);			 
    [AppKey, "symmetrical_key"] ->
	io:format("~s: symmetrical key = ~p~n", [AppKey,
				    easemob_encrypt:get_symmetrical_key(list_to_binary(AppKey))]);
     _ ->
	io:format("Error format, Pls input <AppKey> <KeyType> ~n", [])
end,
ok.
			 
