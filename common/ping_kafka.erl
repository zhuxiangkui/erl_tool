echo(off),

From = <<"kafka#test_from@easemob.com">>,
To = <<"kafka#test_to@easemob.com">>,
MId = <<"kafka_mid1">>,
Payload = <<"kafka message body 1">>,

PingRedisWorker =
fun(Table, N, Pid) ->
	try
            Timestamp = os:timestamp(),
            ChatMsgOutgoing = {chatmsg, Timestamp, <<"chat">>, outgoing, From, To, <<"kafka message body 1">>, <<"kafka_mid1">>},
            case timer:tc(gen_server,call,[Pid, ChatMsgOutgoing]) of
                {Time, ok} ->
                    io:format("worker is all right: ~w ~w ms ~w ~w~n",[node(), Time/1000, N,Pid]),
                    ok;
                {Time, Value} ->
                    io:format("worker is fail: ~w Reason: ~p ~w ~w ~w~n",[node(), Value, 50000, N,Pid])
            end
	catch
	    Class:Type ->
		io:format("error:~w ~w ~w ~w~n",[node(), 60000, N,Pid])
	end
end,

[{pool_size, PoolSize}] = ets:lookup(log_kafka, pool_size),

PingKafkaN =
fun(N) ->
        try ets:lookup(log_kafka, N) of
            [{N, Worker}] ->
                PingRedisWorker(log_kafka, N, Worker)
        catch
            C2:E2 ->
                io:format("error:~p ~p:~p ~pno worker ~n", [node(), C2, E2, N])
        end
end,
lists:foreach(PingKafkaN, lists:seq(1, PoolSize)),

ok.
