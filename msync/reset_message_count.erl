% input: AppKey Num
%
% op: reset message count
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-msync3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/reset_message_count.erl

echo(off),

case easemob_redis:q(index, [set, <<"im:message:count">>, 0]) of
    {ok, _} ->
        io:format("reset ok~n");
    _ ->
        io:format("reset failed~n")
end,
ok.
