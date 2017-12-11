% op: clean msync socket bad ets
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/clean_bad_ets.erl

FindBadSocket =
fun() ->
        ets:foldl(
          fun(Elem, {GoodNum, BadSockets}) ->
                  Socket = element(1,Elem),
                  case is_port(Socket) of
                      true ->
                          case erlang:port_info(Socket) of
                              undefined ->
                                  {GoodNum, [Socket|BadSockets]};
                              _ ->
                                  {GoodNum+1, BadSockets}
                          end;
                      false ->
                          throw(bad_socket)
                  end
          end, {0,[]}, msync_c2s_tbl_sockets)
end,
FindBadJID =
fun() ->
        ets:foldl(
          fun(Elem, {GoodNum, BadList}) ->
                  JID = element(1,Elem),
                  Socket = element(3,Elem),
                  {_,{Pid,msync}} = element(4,Elem),
                  case is_process_alive(Pid) of
                      false ->
                          {GoodNum, [Elem|BadList]};
                      true ->
                          {GoodNum+1, BadList}
                  end
          end, {0,[]}, msync_c2s_tbl_pb_jid)
end,
CanDel = fun(GoodNum, ClientNum) ->
                 abs(ClientNum-GoodNum) =< 0.05 * ClientNum
         end,

Clean = fun()->
            ClientNum = length(supervisor:which_children(msync_client_sup)),
            {GoodSocketNum, BadSockets} = FindBadSocket(),
            io:format("Node:~p,GoodSocketNum:~p,BadSocketNum:~p,ClientNum:~p~n",
                     [node(), GoodSocketNum, length(BadSockets), ClientNum]),
            timer:sleep(5000),
            case CanDel(GoodSocketNum, ClientNum) of
                true ->
                    [ets:delete(msync_c2s_tbl_sockets, Socket)||Socket<-BadSockets];
                false ->
                    throw({not_del, GoodSocketNum, ClientNum})
            end,
            {GoodJIDNum, BadJIDs} = FindBadJID(),
            io:format("Node:~p,GoodJIDNum:~p,BadJIDNum:~p,ClientNum:~p~n",
                     [node(), GoodJIDNum, length(BadJIDs), ClientNum]),
            timer:sleep(5000),
            case CanDel(GoodJIDNum, ClientNum) of
                true ->
                    [ets:delete_object(msync_c2s_tbl_pb_jid, Elem)||Elem<-BadJIDs];
                false ->
                    throw({not_del, GoodJIDNum, ClientNum})
            end,
            ok
    end,

Clean().

