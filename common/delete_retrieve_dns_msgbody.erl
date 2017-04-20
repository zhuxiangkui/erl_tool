% input: RunMode
%
% op: delete msg according to given jid
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/delete_retrieve_dns_msgbody.erl RunMode

echo(off),

%% RunMode: delete | dry_run

[RunMode] = Args,

DoDelete =
    fun(Jid) ->
        io:format("Jid: ~p~n", [Jid]),
        Mids = message_store:get_messages_index(<<Jid/binary, "@easemob.com">>, <<"">>),
        %io:format("length of Mids: ~p~n", [erlang:length(Mids)]),
        lists:foreach( fun(Mid) ->
            %Body = <<"<message from='yaomaitong#yaomaitong_admin@easemob.com' to='yaomaitong#yaomaitong_im_450ce0f9c36b4444bfec8d68c003cf18@easemob.com' id='285848519443484000' type='chat'><body>{&quot;from&quot;:&quot;admin&quot;,&quot;to&quot;:&quot;im_450ce0f9c36b4444bfec8d68c003cf18&quot;,&quot;bodies&quot;:[{&quot;action&quot;:&quot;em_retrieve_dns&quot;,&quot;type&quot;:&quot;cmd&quot;}]}</body><delay xmlns='urn:xmpp:delay' stamp='2017-01-11T07:18:14.788Z'/></message>">>,
            %Body = <<"<message from='yaomaitong#yaomaitong_admin@easemob.com' to='yaomaitong#yaomaitong_im_450ce0f9c36b4444bfec8d68c003cf18@easemob.com' id='286546254677151052' type='chat'><body>{&quot;from&quot;:&quot;yaomaitong_xiaoxi&quot;,&quot;to&quot;:&quot;im_450ce0f9c36b4444bfec8d68c003cf18&quot;,&quot;bodies&quot;:[{&quot;msg&quot;:&quot;您好，您重新登录试一下&quot;,&quot;type&quot;:&quot;txt&quot;}],&quot;ext&quot;:{&quot;weichat&quot;:{&quot;msgId&quot;:&quot;1a9f64aa-c91e-4e33-8aac-47fe433fd6d4&quot;,&quot;originType&quot;:null,&quot;visitor&quot;:null,&quot;agent&quot;:{&quot;avatar&quot;:null,&quot;userNickname&quot;:null},&quot;queueId&quot;:null,&quot;queueName&quot;:null,&quot;agentUsername&quot;:null,&quot;ctrlType&quot;:null,&quot;ctrlArgs&quot;:null,&quot;event&quot;:null,&quot;metadata&quot;:null,&quot;callcenter&quot;:null,&quot;language&quot;:null,&quot;service_session&quot;:null,&quot;html_safe_body&quot;:{&quot;type&quot;:&quot;txt&quot;,&quot;msg&quot;:&quot;您好，您重新登录试一下&quot;},&quot;msg_id_for_ack&quot;:null,&quot;ack_for_msg_id&quot;:null},&quot;extras&quot;:{&quot;emNickName&quot;:&quot;子皿&quot;,&quot;emUserId&quot;:&quot;3af01ee196784860bd86ec0d8155155f&quot;,&quot;emHeadPhotoUrl&quot;:&quot;http://image1.cdn.yaomaitong.cn/user/476e23fe5ff44814af0a55e7e775782c.jpg-img_s&quot;}}}</body><delay xmlns='urn:xmpp:delay' stamp='2017-01-13T04:25:48.936Z'/></message>">>,
            Body = message_store:read_message(Mid),
            %io:format("Body: ~p~n", [Body]),
            case Body of
                not_found ->
                    ignore;
                _ ->
                    try
                        Xml = msync2xmpp:to_xml(Body, jlib:jid_to_user(jlib:string_to_jid(<<Jid/binary, "@easemob.com">>))),
                        %io:format("Xml: ~p~n", [Xml]),
                        Body2 = xml:get_path_s(Xml, [{elem, list_to_binary("body")}, cdata]),
                        case jsx:is_json(Body2) of
                            true ->
                                BodyMap = jsx:decode(Body2, [return_maps]),
                                %io:format("BodyMap: ~p~n", [BodyMap]),
                                case BodyMap of
                                    #{<<"bodies">> := [#{<<"action">> := <<"em_retrieve_dns">>} | _]} ->
                                        case RunMode of
                                            "delete" ->
                                                io:format("[delete] Jid: ~p, Mid: ~p, Body: ~p~n", [Jid, Mid, Body]),
                                                RedisWorker = cuesport:get_worker(body),
                                                SSDBWorker = cuesport:get_worker(ssdb_body),    
                                                easemob_redis:q(RedisWorker, [del, <<"im:message:", Mid/binary>>]),
                                                easemob_redis:q(SSDBWorker, [del, <<"im:message:", Mid/binary>>]);
                                            "dry_run" ->
                                                io:format("[dry_run] Jid: ~p, Mid: ~p, Body: ~p~n", [Jid, Mid, Body]),
                                                ignore;
                                            _ ->
                                                io:format("[wrong mode, wrong usage]~n"),
                                                ignore
                                        end;
                                    _ ->
                                        %io:format("not em_retrieve dns cmd, Mid: ~p~n", [Mid]),
                                        ignore
                                end;
                            false ->
                                io:format("Not json, Jid: ~p, Mid: ~p, Body: ~p~n", [Jid, Mid, Body])
                        end
                    catch 
                        Class:Exception ->
                            io:format("Jid: ~p, Mid: ~P, Class:Exception: ~p:~p~n", [Jid, Mid, Class, Exception])
                    end
            end
        end, Mids)
    end,

LoopDelete =
    fun ReadStdIO() ->
        case io:get_line('') of
            eof ->
                ignore;
            {error, _} ->
                ReadStdIO();
            Jid0 ->
                %io:format("Jid0: ~p~n", [Jid0]),
                DoDelete(list_to_binary(string:strip(Jid0, both, $\n))),
                ReadStdIO()
        end
    end,

LoopDelete().


