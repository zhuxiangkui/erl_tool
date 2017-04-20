%
% input: none
%
% op: check whether is at bypass mode
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/check_bypass.erl

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

{A, B, C} = os:timestamp(),
random:seed(A, B, C).
User = random:uniform(100),
PassWrod = random:uniform(200),
case IsEjabberd() of
    true ->
        extauth_rpc:check_password(integer_to_binary(User), <<"easemob.com">>, Password);
    false ->
        Jid = <<"easemob-demo#chatdemoui_", User/integer, "@easemob.com/mobile">>,
        msync_c2s_handler_auth:try_authenticate(#'MSync'{guid=Jid, auth=PassWrod})
end,

ok.
