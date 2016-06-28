echo(on),
{ok, LogKafkaConfig} = application:get_env(message_store, log_kafka),
OutgoingMsgTopic = proplists:get_value(kafka_outgoing_msg_topic, LogKafkaConfig, <<"ejabberd-chat-messages">>),
IncomingMsgTopic = proplists:get_value(kafka_incoming_msg_topic, LogKafkaConfig, <<"ejabberd-chat-recvmsgs">>),
OfflineMsgTopic = proplists:get_value(kafka_offline_msg_topic, LogKafkaConfig, <<"ejabberd-chat-offlines">>),
AckMsgTopic = proplists:get_value(kafka_ackmsg_topic, LogKafkaConfig, <<"im-ack-messages">>),
IncomingMsgLargeGroupTopic = proplists:get_value(kafka_incoming_msg_large_group_topic, LogKafkaConfig, <<"im-incoming-messages-large-group">>),
OfflineMsgLargeGroupTopic = proplists:get_value(kafka_offline_msg_large_group_topic, LogKafkaConfig, <<"im-offline-messages-large-group">>),
AckMsgLargeGroupTopic = proplists:get_value(kafka_ackmsg_large_group_topic, LogKafkaConfig, <<"im-ack-messages-large-group">>),
StatusTopic = proplists:get_value(kafka_status_topic, LogKafkaConfig, <<"ejabberd-user-status-change">>),
MucOptTopic = proplists:get_value(kafka_muc_opt_topic, LogKafkaConfig, <<"ejabberd-muc-opt">>),
MucMemTopic = proplists:get_value(kafka_muc_member_topic, LogKafkaConfig, <<"ejabberd-muc-mem">>),
KafkaPort = proplists:get_value(kafka_broker_port, LogKafkaConfig, 9148),

Topics = [OutgoingMsgTopic, IncomingMsgTopic, OfflineMsgTopic, AckMsgTopic, IncomingMsgLargeGroupTopic, OfflineMsgLargeGroupTopic, AckMsgLargeGroupTopic, StatusTopic, MucOptTopic, MucMemTopic],
application:stop(ekaf),
application:ensure_all_started(ekaf),
lists:map(fun(Topic) ->
		  io:format("init topic ~s~n",[Topic]),
		  ekaf:prepare(Topic)
	  end, Topics),

ok.

