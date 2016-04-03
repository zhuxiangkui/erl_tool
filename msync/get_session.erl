[App, Name | _] =  Args,
Session = ejabberd_bridge:rpc(ejabberd_sm, get_session, [<<"easemob-demo#", (list_to_binary(App))/binary, "_", (list_to_binary(Name))/binary>>, <<"easemob.com">>, <<"mobile">>]),
case Session of
    [{session,_,{_, Pid}, _, _, _}] when is_pid(Pid) ->
	io:format("~p~n", [node(Pid)]);
    _ ->
	ok
end.

