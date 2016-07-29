
% input: none
%
% op: get session, codis or mnesia
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_session_db_type.erl

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

case IsEjabberd() of
    true ->
        application:get_env(ejabberd, session_db_type, mnesia);
    false ->
        easemob_session:get_session_db_type()
end

ok.
