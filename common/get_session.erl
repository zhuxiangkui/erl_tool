
% input: JID
%
% op: get session for JID
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_session.erl JID

echo(on),
[JID,Resource] = case Args of
                     [ID] ->
                         [ID, <<"mobile">>];
                     [ID, R] ->
                         [ID, list_to_binary(R)]
                 end,
Session = ejabberd_sm:get_session(
            iolist_to_binary(JID), <<"easemob.com">>, Resource),
case Session of
    [{session,_,{_, Pid}, _, _, _}] when is_pid(Pid) ->
        io:format("Pid = ~p, Node = ~p~n", [Pid, node(Pid)]);
    [{session,_,{_, {msync_c2s, Node}}, _, _, Info}] ->
        io:format("Socket = ~p, Node = ~p~n", [proplists:get_value(socket, Info, undefined),Node]);
    _ ->
        ok
end.
