%% input: QueueId Speed
%%
%% op: change queue read speed
%% QueueId: integer or string

%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/msglimit_change_queue_speed.erl 1 100
%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/msglimit_change_queue_speed.erl message_limit_queue_1 100
%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/msglimit_change_queue_speed.erl message_limit_queue_10 100
%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/msglimit_change_queue_speed.erl kafka_message_queue_large_chatroom_low_1 100
%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/msglimit_change_queue_speed.erl kafka_message_queue_large_chatroom_normal_1 100
%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/msglimit_change_queue_speed.erl kafka_message_queue_large_group_normal_1 100

echo(off),
case Args of
    [QueueId, Speed] ->
        io:format("change_queue_speed QueueId:~s,Speed:~s,result:~p~n",
                  [QueueId, Speed,
                   mod_message_limit:change_queue_speed(list_to_binary(QueueId),
                                               list_to_integer(Speed))])
end,
ok.
