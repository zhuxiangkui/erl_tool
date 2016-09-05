
% input: none
%
% op: set codis session
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/set_session_db_type_to_codis.erl

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
        ejabberd_sm:set_session_db_type(redis);
    false ->
        easemob_session:set_session_db_type(redis)
end,

ok.
