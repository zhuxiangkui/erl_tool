% input: AppKey Speed QueueId
% input: AppKey
%
% op: limit app muc message send speed
%
% Speed: the speed on each worker node, if there is N node , the real limit speed is Speed * min(N,50)
% QueueId: limit App to which queue. Start from 1 to queue_num, now queue_num=10 
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/msglimit_limit_app.erl easemob-demo#chatdemoui 100 1
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/msglimit_limit_app.erl easemob-demo#chatdemoui

echo(off),
case Args of
    [AppKey, Speed, QueueId] ->
        io:format("limit App:~s,Speed:~s,QueueId:~s,result:~p~n", 
                  [AppKey, Speed, QueueId, 
                   mod_message_limit:limit_app(list_to_binary(AppKey), 
                                               list_to_integer(Speed), 
                                               list_to_integer(QueueId))]);
    [AppKey] ->
        Speed = 1,
        QueueId = 1,
        io:format("limit App:~s,Speed:~s,QueueId:~s,result:~p~n",
                  [AppKey, Speed, QueueId,
                   mod_message_limit:limit_app(list_to_binary(AppKey),
                                               list_to_integer(Speed),
                                               list_to_integer(QueueId))])
end,
ok.
