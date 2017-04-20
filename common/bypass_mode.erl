% input: enable | disable
%
% op: enable or disable bypass mode for ejabberd / msync
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd' common/bypass_mode.erl disable
%       bypass mode is disabled

echo(off),

Enabled =
fun(true) ->
        "enabled";
(false) ->
        "disabled"
end,

IsEjabberd =
fun() ->
        case lists:keysearch(ejabberd, 1, application:which_applications()) of
            {Value, _} ->
                true;
            _ ->
                false
        end
end,

SetOpt =
fun(Value) ->
        case IsEjabberd() of
            true ->
                extauth_rpc:extauth_opts(<<"easemob.com">>, bypassed, Value);
            false ->
                case Value of
                    true ->
                        application:set_env(msync, user_auth_module, blackhole);
                    false ->
                        msync_user:auth_opt(bypassed, Value)
                end
        end
end,

GetOpt =
fun() ->
        case IsEjabberd() of
            true ->
                extauth_rpc:extauth_opts(<<"easemob.com">>, bypassed);
            false ->
                msync_user:auth_opt(bypassed)
        end
end,


case Args of
    ["enable"] ->
        SetOpt(true),
        io:format("bypass mode is ~s~n", [Enabled(GetOpt())]);
    ["disable"] ->
        SetOpt(false),
        io:format("bypass mode is ~s~n", [Enabled(GetOpt())]);
    [] ->
        io:format("bypass mode is ~s~n", [Enabled(GetOpt())]);
    _ ->
        io:format("usage: bypass_mode.erl [enable/disable]~n",[])
end,
ok.
