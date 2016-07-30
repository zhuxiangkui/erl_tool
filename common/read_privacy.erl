[User] = Args,
io:format("User~p ~n", [User]),
mod_privacy:read_privacy_cache(User, <<"easemob.com">>).
