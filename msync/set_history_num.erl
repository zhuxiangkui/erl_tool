% input: AppKey Num
%
% op: set chat history num
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-msync3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/set_history_num.erl easemob#demo 100

echo(off),

case Args of
    [RawAppKey, RawNum] ->
        AppKey = list_to_binary(RawAppKey),
        Num = list_to_integer(RawNum),
        app_config:set_app_config(AppKey, chat_history_num, Num),
        io:format("set history num ok, num = ~p~n", [Num]);
    _ ->
        io:format("wrong args~n")
end,
ok.
