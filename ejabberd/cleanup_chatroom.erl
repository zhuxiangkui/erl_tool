echo(off),

Worker = mod_easemob_cache_query_cmd:client(any),

IsUserDirty =
fun(User, ChatRoomId) ->
        case eredis:q(Worker, [hget, iolist_to_binary(["im:", ChatRoomId]), "type"]) of
            {ok, <<"chatroom">>} ->
                case eredis:q(Worker, [zrank, iolist_to_binary(["im:", ChatRoomId, ":affiliations"]),
                                       User
                                      ]) of
                    {ok, B} when is_binary(B) ->
                        case ejabberd_sm:get_user_resources(
                               iolist_to_binary(User), <<"easemob.com">>) of
                            [] ->
                                %% 1. room is a chat room,
                                %% 2. user is in the chat room
                                %% 3. user is not online
                                true;
                            _X ->
                                io:format("                          resource User ~p/~p~n", [User,_X]),
                                false
                        end;
                    _Y ->
                        io:format("                          rank User ~p~n", [_Y]),
                        false
                end;
            _ ->
                false
        end
end,

GetAffiliations =
fun(ChatRoomId) ->
        case eredis:q(Worker, [hget, iolist_to_binary(["im:", ChatRoomId]), "type"]) of
            {ok, <<"chatroom">>} ->
                case eredis:q(Worker, [zrange, iolist_to_binary(["im:", ChatRoomId, ":affiliations"]), 0, -1]) of
                    {ok, Affiliations} when is_list(Affiliations) ->
                        Affiliations;
                    _ ->
                        []
                end;
            _ ->
                []
        end
end,


DoClean =
fun(ChatRoomId) ->
        case lists:flatmap(
               fun(User) ->
                       io:format("~p ~p~n",[User, ChatRoomId]),
                       case IsUserDirty(User, ChatRoomId) of
                           true ->
                               [[zrem, iolist_to_binary(["im:", ChatRoomId, ":affiliations"]), User],
                                [zrem, iolist_to_binary(["im:", User, ":groups"]), ChatRoomId],
                                [zrem, iolist_to_binary(["im:", ChatRoomId, ":groups"]), User]
                               ];
                           _ ->
                               []
                       end
               end, GetAffiliations(ChatRoomId)) of
            [] ->
                ok;
            QP when is_list(QP) ->
                try
                    Results = eredis:qp(Worker, QP),
                    io:format("redis ~p => ~p~n", [QP, Results]),
                    case muc_mnesia:rpc_get_online_room(iolist_to_binary([ChatRoomId]), <<"conference.easemob.com">>) of
                        [{_,_,Pid}] ->
                            io:format("stopping group process ~p @ ~p ~n", [Pid, node(Pid)]),
                            muc_mnesia:rpc_delete_online_room(<<"conference.easemob.com">>, ChatRoomId, Pid);
                        _ ->
                            ok
                    end
                catch
                    Class:Error ->
                        io:format("clean QP = ~p from room ~s ok~n", [QP, ChatRoomId])
                end
        end
end,

ChatRoomIdExample = <<"easemob-demo#chatdemoui_181611163585347584">>,
DoClean(ChatRoomIdExample),
ok.

%% lists:foreach(
%%   fun({_,{Name, Host},Pid}) ->
%%           case rpc:call(node(Pid), erlang, is_process_alive, [Pid]) of
%%               true ->
%%                   ok;
%%               _ ->
%%                   muc_mnesia:rpc_delete_online_room(Host, Name, Pid),
%%                   io:format("~p @ ~p is dirty~n", [Name, node(Pid)])
%%           end
%%   end,
%%   muc_mnesia:rpc_get_vh_rooms(<<"conference.easemob.com">>)).
