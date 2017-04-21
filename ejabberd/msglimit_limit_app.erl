% input: AppKey Speed QueueId
%
% op: limit app muc message send speed
%
% Speed: the speed on each msglimit consume node, if there is 2 node , the real limit speed is Speed * 2
% QueueId: limit App to which queue. Start from 1 to queue_num, now queue_num=10 
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/msglimit_limit_app.erl easemob-demo#chatdemoui 100 1

echo(off),
case Args of
    [AppKey, Speed, QueueId] ->
        io:format("limit App:~s,Speed:~s,QueueId:~s,result:~p~n", 
                  [AppKey, Speed, QueueId, 
                   mod_message_limit:limit_app(list_to_binary(AppKey), 
                                               list_to_integer(Speed), 
                                               list_to_integer(QueueId))])
end,
ok.
