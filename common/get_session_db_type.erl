% input: none
%
% op: get session, codis or mnesia
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/get_session_db_type.erl 
% 		session_db_type = redis

echo(off),

IsEjabberd =
fun() ->
        case lists:keysearch(ejabberd, 1, application:which_applications()) of
            {Value, _} ->
                true;
            _ ->
                false
        end
end,

Type = case IsEjabberd() of
    true ->
        application:get_env(ejabberd, session_db_type, mnesia);
    false ->
        easemob_session:get_session_db_type()
end,
io:format("session_db_type = ~p~n",[Type]),
ok.
