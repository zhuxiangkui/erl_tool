[UserFile] = Args,
io:format("UserFile~p ~n", [UserFile]),
{ok, UserList} = file:consult(UserFile),
lists:foreach(fun(User) -> mod_roster:get_roster(User, <<"easemob.com">>) end, UserList).
