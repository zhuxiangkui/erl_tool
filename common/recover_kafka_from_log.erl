% input: none
%
% op: recover ekaf
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/recover_kafka_from_log.erl "/data/apps/opt/ejabberd/var/log/ejabberd.log.0" 

echo(off),
case Args of
	[LogFile] ->
		IsWriteKafka = true;
	[LogFile, "true"] ->
		IsWriteKafka = true;
	[LogFile, "false"] ->
		IsWriteKafka = false
end,

INFO = fun(Format, Args) ->
               error_logger:info_msg(Format, Args)
       end,
ERROR_MSG = fun(Format, Args) ->
               error_logger:error_msg(Format, Args)
       end,
StrToTerm = fun(Str) ->
                    case erl_scan:string(Str++".") of
                        {ok, Tokens,_} ->
                            case catch erl_parse:parse_term(Tokens) of
                                {ok, Term} ->
                                    Term;
                                _Err ->
                                    undefined
                            end;
                        _Err ->
                            undefined
                    end
            end,

IsProduceError = fun(Data) ->
                         string:str(Data, "Produce error") /= 0
                 end,
IsProduceTimeout = fun(Data) ->
                           string:str(Data, "{'EXIT',{timeout,{gen_fsm,") /= 0
                   end, 
ParseMessage1 = fun(Data) ->
                        StartStr = "{produce_sync,<<",
                        EndStr = ">>},5000]}}} on message",
                        case string:str(Data, StartStr) of
                            0 -> {fail, no_start};
                            Start ->
                                case string:str(Data, EndStr) of
                                    0 -> 
                                        {fail, no_end};
                                    End ->
                                        StrBin = string:substr(Data, Start+length(StartStr)-2,End-Start-length(StartStr)+4),
                                        case StrToTerm(StrBin) of
                                            undefined ->
                                                {fail, bad_term};
                                            Str ->
                                                {ok, Str}
                                        end
                                end
                        end
                end,      
ParseMessage2 = fun(Data) ->
                        StartStr = "on message ",
                        case string:str(Data, StartStr) of
                            0 -> {fail, no_start};
                            Start ->
                                StrRaw = string:substr(Data, Start+length(StartStr), length(Data)-Start-length(StartStr)-1), 
								Str = iolist_to_binary(io_lib:format("~ts",[iolist_to_binary(StrRaw)])),
                                {ok, Str}
                        end
                end,
{ok, LogKafkaConfig} = application:get_env(message_store, log_kafka),
INFO("Config:~p~n", [LogKafkaConfig]),
OutgoingMsgTopic = proplists:get_value(kafka_outgoing_msg_topic, LogKafkaConfig, <<"ejabberd-chat-messages">>),
IncomingMsgTopic = proplists:get_value(kafka_incoming_msg_topic, LogKafkaConfig, <<"ejabberd-chat-recvmsgs">>),
OfflineMsgTopic = proplists:get_value(kafka_offline_msg_topic, LogKafkaConfig, <<"ejabberd-chat-offlines">>),
AckMsgTopic = proplists:get_value(kafka_ackmsg_topic, LogKafkaConfig, <<"im-ack-messages">>),
StatusTopic = proplists:get_value(kafka_status_topic, LogKafkaConfig, <<"ejabberd-user-status-change">>),
MucOptTopic = proplists:get_value(kafka_muc_opt_topic, LogKafkaConfig, <<"ejabberd-muc-opt">>),
MucMemTopic = proplists:get_value(kafka_muc_member_topic, LogKafkaConfig, <<"ejabberd-muc-mem">>),

FindTopic = fun(Plist) ->
                    case proplists:get_value(<<"direction">>, Plist) of
                        undefined ->
                            case proplists:get_value(<<"status">>, Plist) of
                                undefined ->
                                    case proplists:get_value(<<"approval">>, Plist) of
                                        undefined ->
                                            case proplists:get_value(<<"operation">>, Plist) of
                                                undefined -> undefined;
                                                _ ->
                                                    MucMemTopic
                                            end;
                                        _ ->
                                            MucOptTopic
                                    end;
                                <<"online">> ->
                                    StatusTopic;
                                <<"offline">> ->
                                    StatusTopic
                            end;
                        <<"offline">> ->
                            OfflineMsgTopic;
                        <<"incoming">> ->
                            IncomingMsgTopic;
                        <<"outgoing">> ->
                            OutgoingMsgTopic;
                        <<"ack">> ->
                            AckMsgTopic
                    end
            end,
SendToKafka = fun(Topic, Value) ->
                      case catch ekaf:produce_sync(Topic, Value ) of
                          {{sent,_,_}, Res} ->
                              INFO("RepairKafka: Produce ok: ~p on message ~s ~n", [Topic, Value]),
                              ok;
                          ok ->
                              INFO("RepairKafka: Produce ok: ~p on message ~s ~n", [Topic, Value]),
                              ok;
                          Error ->
                              ERROR_MSG("RepairKafka: ProduceError: ~p on message ~s ~n", [Error, Value]),
                              {fail, Error}
                      end
              end,
HandleMsg = fun(Str) ->
                    try
                        INFO("HandleMsg:~s~n",[Str]),
                        Plist = jsx:decode(Str),
                        case FindTopic(Plist) of
                            undefined -> 
                                ERROR_MSG("RepairKafka: Cannot Find Topic:plist=~p~n", [Plist]),
                                {fail, skip};
                            TopicName ->
                                case IsWriteKafka of
                                    true ->
                                        SendToKafka(TopicName, Str);
                                    false ->
                                        INFO("RepairKafka: SkipWriteKafka:Topic=~p,Str=~s~n", [TopicName, Str]),
                                        ok
                                end
                        end
                    catch
                        E:R ->
                            ERROR_MSG("RepairKafka: HandleMsgError: E:~p,E:~p,Str:~ts~n,T:~p~n", [E,R,Str,erlang:get_stacktrace()]),
							{fail, exit}
                    end
            end,
HandleLine = fun(Data) ->
                     case IsProduceError(Data) andalso (not IsProduceTimeout(Data)) of
                         false -> 
                             {fail, skip};
                         true ->
                             case ParseMessage1(Data) of
                                 {fail, _} ->
                                     case ParseMessage2(Data) of
                                         {fail, Reason} ->
                                             {fail, Reason};
                                         {ok, Str2} ->
                                             HandleMsg(Str2)
                                     end;
                                 {ok, Str} ->
                                     HandleMsg(Str)
                             end
                     end
             end,
case whereis(recover_kafka_from_log) of
    undefined ->
        spawn(fun() ->
                      register(recover_kafka_from_log, self()),
                      {ok,Fd} = file:open(LogFile, [read]),
                      Loop = fun TLoop() ->
                                     case file:read_line(Fd) of
                                         {ok, Data} ->
                                             case HandleLine(Data) of
                                                 {fail, skip} ->
                                                     skip;
                                                 {fail, Reason} ->
                                                     ERROR_MSG("HandleFail:reason:~p,Data:~s~n", [Reason, Data]);
                                                 ok ->
                                                     ok
                                             end,
                                             TLoop();
                                         Other ->
                                             INFO("Other:~p~n", [Other])
                                     end
                             end,
                      Loop(),
                      file:close(Fd),
                      INFO("RepairKafka: finished~n", [])
              end);
    _ ->
        io:format("error:another_repair_is_running~n")
end,
ok.
