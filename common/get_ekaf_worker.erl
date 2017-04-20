% input: none
%
% op: look up info of ekaf
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd' common/get_ekaf_worker.erl
%		Topics:[<<"ejabberd-chat-messages">>,<<"ejabberd-chat-recvmsgs">>,
%       	<<"ejabberd-chat-offlines">>,<<"im-messages-deliver">>,
%       	<<"im-messages-offline">>,<<"im-messages-ack">>,
%       	<<"im-messages-ack-large-group">>,<<"ejabberd-muc-opt">>,
%       	<<"ejabberd-muc-mem">>]
% 		WorkerChecks Len:98

echo(off),
LogKafkaOpts = application:get_env(message_store, log_kafka, []),
Topics =
lists:filtermap(
  fun({_, T}) when is_binary(T) ->
          {true, T};
     (_) -> false
  end, LogKafkaOpts),
io:format("Topics:~p ~n", [Topics]),

GetPartitions =
fun(Topic) ->
        LogKafkaOpts = application:get_env(message_store, log_kafka, []),
        KafkaHost = proplists:get_value(kafka_broker_host, LogKafkaOpts),
        KafkaPort = proplists:get_value(kafka_broker_port, LogKafkaOpts),
        try
            {ok, Sock} = ekaf_socket:open({KafkaHost, KafkaPort}),
            Req = ekaf_protocol:encode_metadata_request(
                    0, "ekaf", [Topic]),
            gen_tcp:send(Sock, Req),
            receive
                {tcp, Sock, Packet = <<_CorrelationId:32, _/binary>>} ->
                    ekaf_socket:close(Sock),
                    case ekaf_protocol:decode_metadata_response(Packet) of
                        {metadata_response, _CID, _Bs, Ts} ->
                            case lists:keyfind(topic, 1, Ts) of
                                {topic, Topic1, _ECode, Ps}
                                  when Topic1 == Topic-> Ps;
                                _ -> []
                            end;
                        _ -> []
                    end
            after 5000 ->
                    ekaf_socket:close(Sock),
                    timeout
            end
        catch _C:_E ->
                server_down
        end
end,

GetWorkers =
fun(Topic) ->
        Workers = health_check_utils:get_pool_workers(log_kafka),
        Partitions = GetPartitions(Topic),
        Links = [{kafka_link, Topic, P, Partitions} ||
                    [P, N] <- ets:match(pg2l_table, {{member, Topic, '$1'},'$2'}),
                    _ <- lists:seq(1, N)],
        Workers ++ Links
end,

WorkerChecks =
lists:foldl(fun(T, Out) ->
                    Workers = GetWorkers(T),
                    Out ++ Workers
            end, [], Topics),
io:format("WorkerChecks Len:~p ~n", [erlang:length(WorkerChecks)]),

ok.
