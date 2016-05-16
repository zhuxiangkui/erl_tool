echo(off),
[User] = Args,
LUser = list_to_binary(User),
LServer = <<"easemob.com">>,
mod_roster:remove_user(LUser, LServer).
