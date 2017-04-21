% input: AppKey Speed
%
% op: change app muc message send speed
%
% Speed: the speed on each msglimit consume node, if there is 2 node , the real limit speed is Speed * 2
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/msglimit_change_app_speed.erl easemob-demo#chatdemoui 100
%
% note:This tool is not Use after Ejabberd Release 17.1.7, please use ejabberd/msglimit_change_queue_speed.erl

echo(off),
case Args of
    [AppKey, Speed] ->
        io:format("change_app_speed App:~s,Speed:~s,result:~p~n", 
                  [AppKey, Speed,
                   mod_message_limit:change_app_speed(list_to_binary(AppKey), 
                                               list_to_integer(Speed))])
end,
ok.
