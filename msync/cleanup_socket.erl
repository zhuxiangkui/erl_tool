F = fun(Socket)
          when is_port(Socket) ->
            MaybeJID = msync_c2s_lib:get_socket_prop(Socket,pb_jid),
            %% io:format("~p -> ~p~n",[Socket, MaybeJID]),
            case  MaybeJID of
                {error, not_found} ->
                    {true, Socket};
                _ ->
                    false
            end;
       (_) ->
            false
    end,

lists:foreach(fun gen_tcp:close/1,
              lists:filtermap(F, element(2, process_info(whereis(msync_c2s), links)))).


