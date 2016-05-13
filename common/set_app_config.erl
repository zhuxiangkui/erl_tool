echo(off),

Check =
fun
(use_roster, V) when is_boolean(V) -> true; %% : true 好友
(use_keyword_scan, V) when is_boolean(V) -> true; %% : false  关键字
(roster_only, V) when is_boolean(V) -> true; %% : false roster only 限制
(send_timestamp, V) when is_boolean(V) -> true; %% : false 时间戳
(use_privacy, V) when is_boolean(V) -> true; %% : true 黑名单
(use_sub_store, V) when is_boolean(V) -> true; %% : false 是否使用sub集群
(use_video, V) when is_boolean(V) -> true; %% : true 视频
(use_audio, V) when is_boolean(V) -> true; %% : true 音频
(use_video_turnserver, V) when is_boolean(V) -> true; %% : true 视频turnserver
(use_audio_turnserver, V) when is_boolean(V) -> true; %% : true 音频turnserver
(use_group_maxuser_limit, V) when is_boolean(V) -> true; %% : true 群组最大限制
(use_offline_msg_limit, V) when is_boolean(V) -> true; %%: true 限制离线消息
(use_receive_kafka, V) when is_boolean(V) -> true; %%:  kafka下行消息，与大数据和后台统计、回调相关
(use_offline_kafka, V) when is_boolean(V) -> true; %% kafka离线消息，与大数据和后台统计、回调相关
(use_offline_push, V) when is_boolean(V) -> true; %% 推送消息是否为单独redis队列(false使用单独队列)
(antispam_send, V) when is_boolean(V) -> true; %%  消息内容是否发送给反垃圾系统
(antispam_receive, V) when is_boolean(V) -> true; %% 消息内容是否使用反垃圾功能
(muc_presence, V) when is_boolean(V) -> true; %% 是否使用presence
(muc_presence_async, V) when is_boolean(V) -> true; %% 是否使用presence_async
(separate_worker, V) when is_atom(V) -> true; %% 设置worker node
(Key, Value) ->
    io:format("error: invalid config name or value  ~s=~s~n",[Key, Value]),
    exit(normal)
end,

SetAppConfig =
fun(AppKey, ConfigName, ConfigValue) ->
        app_config:set_app_config_global(AppKey, ConfigName, ConfigValue),
        app_config:load_app_config()
end,

case Args of
    [AppKey, ConfigName, ConfigValue ] ->
        Check(list_to_atom(ConfigName), list_to_atom(ConfigValue)),
        io:format("set ~s:~s = ~s  => ~p~n", [ AppKey, ConfigName, ConfigValue,
                                               SetAppConfig(iolist_to_binary(AppKey),
                                                            list_to_atom(ConfigName),
                                                            list_to_atom(ConfigValue))]);
    _ ->
        io:format("usage: set_app_config.erl <AppKey> <Config> [<Value>]~n",[])
end,
ok.
