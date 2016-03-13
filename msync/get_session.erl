[App, Name | _] =  Args,
ejabberd_bridge:rpc(ejabberd_sm, get_session, [<<"easemob-demo#", (list_to_binary(App))/binary, "_", (list_to_binary(Name))/binary>>, <<"easemob.com">>, <<"mobile">>]).
