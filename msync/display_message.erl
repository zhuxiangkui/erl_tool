% input: Num
%
% op: display message content
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-msync3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/display_message.erl 100

echo(off),

Display =
fun (Keys) ->
        Qs = [[get, Key] || Key <- Keys],
        case easemob_redis:qp(index, Qs) of
            Bodies when is_list(Bodies) ->
                lists:foreach(fun ({ok, B}) ->
                                      try msync_msg:decode_meta(B) of
                                          Message ->
                                              io:format("message body: ~p~n", [Message])
                                      catch
                                          _C: _E ->
                                              ignore
                                      end;
                                  (_) ->
                                      ignore
                              end, Bodies);
            _ ->
                ignore
        end
end,

Scan =
fun S(Cursor, Num) ->
        case Num =< 0 of
            true ->
                io:format("display finished~n"),
                ok;
            false ->
                Size = case Num < 100 of
                           true ->
                               Num;
                           false ->
                               100
                       end,
                case easemob_redis:q(index, [scan, Cursor, match, <<"im:message:*">>, count, Size]) of
                    {ok, [<<"0">>, Keys]} ->
                        Display(Keys),
                        io:format("display finished~n");
                    {ok, [NextCursor, Keys]} ->
                        Display(Keys),
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
