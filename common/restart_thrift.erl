% input: none
%
% op: restart thrift for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/restart_thrift.erl

IsEjabberd =
fun() ->
        case lists:keysearch(ejabberd, 1, application:which_applications()) of
            {Value, _} ->
                true;
            _ ->
                false
        end
end,


case IsEjabberd() of
    true ->
        X1 = restart_module:restart_login(),
        io:format("restart_module:restart_login() => ~p~n",[X1]),
        X2 = extauth_rpc:stop(<<"easemob.com">>),
        io:format("extauth_rpc:stop => ~p~n",[X2]),
        X3 = (catch ets:delete_all_objects(extauth_opts)),
	timer:sleep(10000),
        io:format("ets:delete_all_objects => ~p~n",[X3]),
        X4 = extauth_rpc:start(<<"easemob.com">>),
        io:format("ets:delete_all_objects => ~p~n",[X4]);
    false ->
        io:format("TODO: msync does not support it yet~n",[])
end,
ok.


