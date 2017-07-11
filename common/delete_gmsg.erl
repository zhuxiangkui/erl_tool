% input: Num
%
% op: delete gmsg index
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-msync3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/delete_gmsg.erl 100

echo(off),

Delete =
fun (Keys) ->
        io:format("ks: ~p~n", [Keys]),
        Qs =
            lists:foldl(fun (Key, Acc) ->
                                case binary:match(Key, <<"im:gmsg:cursor">>) of
                                    nomatch ->
                                        [[del, Key] | Acc];
                                    _ ->
                                        Acc
                                end
                        end, [], Keys),
        io:format("qs: ~p~n", [Qs]),
        easemob_redis:qp(index, Qs)
end,

Scan =
fun S(Cursor, Num) ->
        case Num =< 0 of
            true ->
                io:format("deletion finished~n"),
                ok;
            false ->
                Size = case Num < 100 of
                           true ->
                               Num;
                           false ->
                               100
                       end,
                Q = [scan, Cursor, match, <<"im:gmsg:*">>, count, Size],
                case easemob_redis:q(index, Q) of
                    {ok, [<<"0">>, Keys]} ->
                        Delete(Keys),
                        io:format("deletion finished~n");
                    {ok, [NextCursor, Keys]} ->
                        Delete(Keys),
                        S(NextCursor, Num - length(Keys));
                    _ ->
                        ok
                end
        end
end,

        
case Args of
    [RawNum] ->
        Num = list_to_integer(RawNum),
        Scan(0, Num);
    _ ->
        io:format("wrong args~n")
end,
ok.
