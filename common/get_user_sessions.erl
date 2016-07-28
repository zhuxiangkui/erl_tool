
% input: JID
%
% op: get each session of multi resource for JID
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_user_sessions.erl JID

echo(on),
[JID] =  Args,
User = list_to_binary(JID),
Server = <<"easemob.com">>,
Ret = lists:map(fun(R) ->
                        ejabberd_sm:get_session(User, Server, R)
                end, ejabberd_sm:get_user_resources(User, Server)),
io:format("~p ~n", [Ret]).
