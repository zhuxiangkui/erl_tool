echo(on),
[JID0] = Args,


JID = msync_msg:parse_jid(iolist_to_binary([JID0, "@easemob.com/mobile"])),
case  msync_c2s_lib:get_pb_jid_prop(JID,socket) of
    {ok, Socket} ->
        %% ets:lookup(msync_c2s_tbl_sockets, Socket),

        %%io:format("Socket = ~p~n", [ Socket ]),
        io:format("JID = ~p~n", [ (catch msync_c2s_lib:get_socket_prop(Socket, pb_jid))]),
        io:format("Version = ~p~n", [ (catch msync_c2s_lib:get_socket_prop(Socket, version))]);
    Other ->
        io:format(" not found? ~p~n",[Other])
end,
ok.
