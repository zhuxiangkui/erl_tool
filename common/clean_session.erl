% input: Users
%
% op: clean expired session
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/clean_session.erl easemob-demo#chatdemoui_na1
% 

echo(on),
case Args of
    [UserArgs] ->
        User = list_to_binary(UserArgs),
        io:format("User:~p~n", [User]),
        UserReses = ejabberd_sm:get_user_resources(User, <<"easemob.com">>),
        lists:foreach(fun(Res) ->
                              case ejabberd_sm:get_session(User, <<"easemob.com">>, Res) of
                                  [{_, _, _, _, undefined, _}] ->
                                      USR = {User, <<"easemob.com">>, Res},
                                      ejabberd_store:store_rpc(all, mnesia, activity,
                                                               [ejabberd_store:op_by_consistency(),
                                                                fun mnesia:delete/1,
                                                                [{session, USR}], mnesia_frag]),
				      mod_session_redis:logout_session_redis(<<"easemob.com">>, User, Res),
				      io:format("clean undefined session:~p ~n", [Res]);
                                  _ ->
                                      ignore
                              end
                      end, UserReses);
    _ ->
        io:format("args error: ~p ~n",[Args])
end,
ok.
