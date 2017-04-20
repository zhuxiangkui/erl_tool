% input: JID
%
% op: get roster for each JID 
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/read_roster.erl easemob-demo#chatdmeoui_t1

echo(off),
[User] = Args,
Ret = odbc_queries:get_roster(<<"easemob.com">>, User).
io:format("Ret:~p ~n", [Ret]).
