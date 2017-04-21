% input: UID
%
% op: load all messages sent/received for the User
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/message_history.erl UID
%
% note: this tools is out of date

echo(off),
[User0] = Args,
User = list_to_binary(User0),

lists:foreach(
  fun([Mid, Timestamp, Dir, Opposite]) ->
	  io:format("~s\t~s\t~s\t~s~n",[Mid, Timestamp, Dir, Opposite])
  end, mod_message_store:load_message_index(User, <<"conference.easemob.com">>)).
