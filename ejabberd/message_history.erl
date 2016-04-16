echo(off),
[User0] = Args,
User = list_to_binary(User0),

lists:foreach(
  fun([Mid, Timestamp, Dir, Opposite]) ->
	  io:format("~s\t~s\t~s\t~s~n",[Mid, Timestamp, Dir, Opposite])
  end, mod_message_store:load_message_index(User, <<"easemob.com">>)).
