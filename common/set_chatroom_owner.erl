% input: AppKey
%
% op: set owner if AppKey has group without owner
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/set_chatroom_owner.erl easemob-demo#chatdemoui
%		appkey:<<"easemob-demo#chatdemoui">> 
%		ChatRoomsWithOutOwner:[] 

echo(off),
case Args of
    [AppKeyArgs] ->
        AppKey = list_to_binary(AppKeyArgs),
        io:format("appkey:~p ~n", [AppKey]),
        ChatRooms = mod_easemob_cache:get_app_groups(<<"easemob.com">>, AppKey, <<"chatroom">>),
        ChatRoomsWithOutOwner =
            lists:filtermap(fun(GroupId) ->
                                    mod_easemob_cache_query_cmd:get_group_owner(GroupId) == not_found
                        end, ChatRooms),
        io:format("ChatRoomsWithOutOwner:~p ~n", [ChatRoomsWithOutOwner]),
        lists:foreach(fun(GroupIdWithOutOwner) ->
                              P = mod_easemob_cache_query_cmd:redis_query_cmd(add_group_owner, {GroupIdWithOutOwner, <<AppKey/binary, "_admin">>}),
                              mod_easemob_cache_query_cmd:redis_query(P)
                      end, ChatRoomsWithOutOwner);
    _ ->
        io:format("usage: set chatroom owner <AppKey> [<Value> ~p ]~n",[Args])
end,
ok.
