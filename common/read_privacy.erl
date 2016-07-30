[User] = Args,
io:format("User~p ~n", [User]),
PrivacyList = mod_privacy:read_privacy_cache(iolist_to_binary(User), <<"easemob.com">>),
io:format("PrivacyList: ~p ~n", [PrivacyList]).
