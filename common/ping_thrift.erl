%% input: none

%% op: measure redis visit time

%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/ping_thrift.erl auth true

echo(off),
{ThriftType, LogException} =
case Args of
    [ThriftTypeList] ->
        {list_to_atom(ThriftTypeList), false};
    [ThriftTypeList, LogExceptionList] ->
        {list_to_atom(ThriftTypeList), list_to_atom(LogExceptionList)}
end,

Block = false,
Timeout = 1000,
AppKey = <<"easemob-demo#chatdemoui">>,
LUser = <<"easemob-demo#chatdemoui_mt001">>,
To = <<"easemob-demo#chatdemoui_mt002">>,
IP = {127,0,0,1},
case ThriftType of
    auth ->
        UserAuth = {'UserAuth',{'EID',<<"easemob-demo#chatdemoui">>,<<"mt001">>},<<"asd">>,undefined},
        case im_thrift:call(user_service_thrift, login, [UserAuth], Block, Timeout) of
            {ok, _} ->
                ok;
            {exception, _} ->
                ok;
            Exception ->
                case LogException of
                    true ->
                        io:format("Auth thrift exception:~p ~n", [Exception]),
                        exit(1);
                    false ->
                        exit(1)
                end
        end;
    group ->
        UID = <<"mt001">>,
        GID = <<"">>,
        Params = easemob_muc_opt:make_params(AppKey, UID, group, GID),
        case im_thrift:call(groupService_thrift, getUserJoinedGroupList, [Params, 1, 20000, UID], Block, Timeout) of
            {ok, _} ->
                ok;
            {exception, _} ->
                ok;
            Exception ->
                case LogException of
                    true ->
                        io:format("Group thrift exception:~p ~n", [Exception]),
                        exit(1);
                    false ->
                        exit(1)
                end
        end;
    antispam ->
        Message = <<"this is antispam test body">>,
        ChatType = <<"chat">>,
        Timestamp = jlib:timestamp_to_long(os:timestamp()),
        IP1 = erlang:list_to_binary(inet_parse:ntoa(IP)),
        Data = jsx:encode([{app, AppKey}, {sender, LUser}, {acceptor, To}, {time, Timestamp}, {content, Message}, {type, ChatType}, {ip, IP1}]),
        case im_thrift:call(behavior_service_thrift, getBehaviorSpamProb, [Data], Block, Timeout) of
            {ok, _} ->
                ok;
            {exception, _} ->
                ok;
            Exception ->
                case LogException of
                    true ->
                        io:format("Antispam thrift exception:~p ~n", [Exception]),
                        exit(1);
                    false ->
                        exit(1)
                end
        end;
    keyword ->
        Message = <<"this is keyword test body">>,
        case im_thrift:call(text_parse_service_thrift, parseWords, [AppKey, Message], Block, Timeout) of
            {ok, _} ->
                ok;
            {exception, _} ->
                ok;
            Exception ->
                case LogException of
                    true ->
                        io:format("Keyword thrift exception:~p ~n", [Exception]),
                        exit(1);
                    false ->
                        exit(1)
                end
        end;
    conference ->
        case im_thrift:call(conference_service_thrift, createP2PVoice, [LUser, inet_parse:ntoa(IP), To, inet_parse:ntoa(IP)], Block, Timeout) of
            {ok, _} ->
                ok;
            {exception, _} ->
                ok;
            Exception ->
                case LogException of
                    true ->
                        io:format("Conference thrift exception:~p ~n", [Exception]),
                        exit(1);
                    false ->
                        exit(1)
                end
        end;
    rtc ->
        XMLB = <<"<iq id='CONFR__2f7729ccfc' from='easemob-demo#chatdemoui_yss001@easemob.com/webim' to='easemob.com' type='get'><query><MediaReqExt><rtflag>1</rtflag><rtkey/><sid>CONFR__2f7729ccfc</sid><content>{&quot;op&quot;:0, &quot;video&quot;:1, &quot;audio&quot;:1, &quot;peer&quot;:&quot;yss002&quot;, &quot;tsxId&quot;:&quot;WEBIM_2f7729ccfc&quot;}</content></MediaReqExt></query></iq>">>,
        XML = xml_stream:parse_element(XMLB),
        Meta = msync_meta_converter:from_xml(XML),
        RtcFrom = jlib:string_to_jid(<<"easemob-demo#chatdemoui_yss001@easemob.com/webim">>),
        RtcTo = jlib:make_jid(<<>>, <<"easemob.com">>, <<>>),
        Header = jsx:encode([{from, jlib:jid_to_string(RtcFrom)},
                             {to, jlib:jid_to_string(RtcTo)},
                             {op, ulmsg}]),
        Binary = msync_msg:encode_meta(Meta),
        case im_thrift:call(rtc_service_thrift, mediaRequest, [Header, Binary], Block, Timeout) of
            {ok, _} ->
                ok;
            {exception, _} ->
                ok;
            Exception ->
                case LogException of
                    true ->
                        io:format("RTC thrift exception:~p ~n", [Exception]),
                        exit(1);
                    false ->
                        exit(1)
                end
        end
end.
