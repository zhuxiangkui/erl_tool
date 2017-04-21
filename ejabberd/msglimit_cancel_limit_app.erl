% input: AppKey
%
% op: cancel the limit of app muc message send speed
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/msglimit_cancel_limit_app.erl easemob-demo#chatdemoui

echo(off),
case Args of
    [AppKey] ->
        io:format("cancel limit App:~s,result:~p~n", 
                  [AppKey,
                   mod_message_limit:unlimit_app(list_to_binary(AppKey))])
end,
ok.
