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
                    io:format("error: worker is fail: ~w Reason: ~p ~w ~w ~w~n",[node(), Value, 50000, N,Pid])
            end
	catch
	    Class:Type ->
		io:format("error: ~w ~w ~w ~w~n",[node(), 60000, N,Pid])
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

LogKafkaOpts = application:get_env(message_store, log_kafka, []),
Topics = lists:filtermap(
           fun({_, T}) when is_binary(T) ->
                   {true, T};
              (_) -> false
           end, LogKafkaOpts),
GetPartitions =
fun(T)->
        KafkaHost = proplists:get_value(kafka_broker_host, LogKafkaOpts),
        KafkaPort = proplists:get_value(kafka_broker_port, LogKafkaOpts),
        try
            {ok, Sock} = ekaf_socket:open({KafkaHost, KafkaPort}),
            Req = ekaf_protocol:encode_metadata_request(
                    0, "ekaf", [T]),
            gen_tcp:controlling_process(Sock, self()),
            gen_tcp:send(Sock, Req),
            Partitions =
            receive
                {tcp, _, Packet = <<_CorrelationId:32, _/binary>>} ->
                    case ekaf_protocol:decode_metadata_response(Packet) of
                        {metadata_response, CorID, Bs, Ts} ->
                            [Pts] = lists:filtermap(
                                      fun({topic, T, ErrCode, Ps}) -> {true, Ps};
                                         (_) -> false
                                      end, Ts),
                            Pts;
                        E -> []
                    end;
                R -> []
            end,
            ekaf_socket:close(Sock),
            Partitions
        catch _C:_E ->
                  server_down
        end
end,
PingWorker =
fun(T, W, Ps) ->
        R = gen_fsm:sync_send_event(W, info, 5000),
        R1 = tuple_to_list(R),
        P = case R1 of
                [ekaf_fsm | _] ->
                    lists:filtermap(
                      fun({partition, ID, _, Leader, _, _, _, _}) -> {true, {ID, Leader}};
                         (E) ->
                              false
                      end, R1);
                _ -> disconnected
            end,
        case P of
            [{ID, Leader}] ->
                lists:any(fun({partition, ID, _, Leader, _, _, _, _}) -> true;
                             (_) -> false
                          end, Ps);
            E -> E
        end
end,

lists:foreach(
  fun(T) ->
          Workers =
          [P || [P, N] <- ets:match(pg2l_table, {{member, T, '$1'},'$2'}),
                _ <- lists:seq(1, N)],
          Partitions = GetPartitions(T),
          case Partitions of
              [] ->
                  io:format("error: ping topic ~p failed~n", [T]);
              [_H|_T] ->
                  lists:foreach(
                    fun(W) ->
                            case PingWorker(T, W, Partitions) of
                                true ->
                                    io:format("ping topic ~p worker ~p ok~n", [T, W]);
                                false ->
                                    io:format("error: ping topic ~p worker ~p leader is old~n", [T, W]);
                                E ->
                                    io:format("error: ping topic ~p worker ~p ~p~n", [T, W, E])
                            end
                    end, Workers);
              Error ->
                  io:format("error: ping topic ~p ~p~n", [T, Error])
          end
  end, Topics),

ok.
