echo(on),
[JID] =  Args,
User = list_to_binary(JID),
Server = <<"easemob.com">>,
Ret = lists:map(fun(R) ->
                        ejabberd_sm:get_session(User, Server, R)
                end, ejabberd_sm:get_user_resources(User, Server)),
io:format("~p ~n", [Ret]).
