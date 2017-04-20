% input: User
%
% op: look up privacy of user
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/read_privacy.erl easemob-demo#chatdemoui_na1
%		User"easemob-demo#chatdemoui_na1" 
%		PrivacyList: not_found

[User] = Args,
io:format("User~p ~n", [User]),
PrivacyList = mod_privacy:read_privacy_cache(iolist_to_binary(User), <<"easemob.com">>),
io:format("PrivacyList: ~p ~n", [PrivacyList]).
