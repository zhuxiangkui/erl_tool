
% input: none
%
% op: restart ekaf
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/restart_ekaf.erl

echo(on),
application:stop(ekaf),
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
KafkaHost = proplists:get_value(kafka_broker_host, LogKafkaConfig, "localhost"),
KafkaPort = proplists:get_value(kafka_broker_port, LogKafkaConfig, 9148),
KafkaWorkers = proplists:get_value(kafka_per_partition_workers, LogKafkaConfig, 2),
PoolSize = proplists:get_value(kafka_pool_size, LogKafkaConfig, 1),
easemob_message_log:bootstrap_ekaf(KafkaHost, KafkaPort, KafkaWorkers),
Topics = [OutgoingMsgTopic, IncomingMsgTopic, OfflineMsgTopic, AckMsgTopic, IncomingMsgLargeGroupTopic, OfflineMsgLargeGroupTopic, AckMsgLargeGroupTopic, StatusTopic, MucOptTopic, MucMemTopic],
easemob_message_log:init_topic(Topics),
ok.
