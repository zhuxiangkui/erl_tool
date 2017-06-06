% input: get/reset
%
% op: reset/get message count
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-msync3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/reset_message_count.erl get

echo(off),

case Args of
    ["get"] ->
        case easemob_redis:q(index, [get, <<"im:message:count">>]) of
            {ok, BN} ->
                io:format("message count: ~p~n", [binary_to_integer(BN)]);
            _ ->
                io:format("get message count failed~p")
        end;
    ["reset"] ->
        case easemob_redis:q(index, [set, <<"im:message:count">>, 0]) of
            {ok, _} ->
                io:format("reset ok~n");
            _ ->
                io:format("reset failed~n")
        end
end,
ok.
