% input: AppKey Num
%
% op: display message content
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-msync3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/display_message.erl 100

echo(off),

Display =
fun (Keys) ->
        lists:foreach(fun (Key) ->
                              io:format("key: ~p~n", [Key]),
                              case easemob_redis:q(index, [get, Key]) of
                                  {ok, Body} ->
                                      try msync_msg:decode_meta(Body) of
                                          Message ->
                                              io:format("message body: ~p~n", [Message])
                                      catch
                                          _C: _E ->
                                              ignore
                                      end;
                                  _ ->
                                      ignore
                              end
                      end, Keys)
          end,

Scan =
fun S(Cursor, Num) ->
        case Num =< 0 of
            true ->
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
                        Display(Keys);
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
