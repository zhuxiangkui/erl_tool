
% input: JIDFile
%
% op: get roster for each JID in file
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/read_roster.erl JIDFile

[UserFile] = Args,
io:format("UserFile~p ~n", [UserFile]),
{ok, UserList} = file:consult(UserFile),
lists:foreach(fun(User) -> mod_roster:get_roster(User, <<"easemob.com">>) end, UserList).
