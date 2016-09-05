
% input: JID
%
% op: get offline msgs for JID
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_offline.erl JID

[JID,Resource] = case Args of
                     [ID] ->
                         [list_to_binary(ID), <<"mobile">>];
                     [ID, R] ->
                         [list_to_binary(ID), list_to_binary(R)]
                 end,

Worker = cuesport:get_worker(index),
{ok, Result} = eredis:q(Worker, [hgetall, iolist_to_binary(["unread:", JID , "@easemob.com/", Resource])]),
io:format("~p~n",[Result]),
lists:foreach(fun(M) ->
                      {ok, List} =
                          eredis:q(Worker,
                                   [lrange,
                                    iolist_to_binary(["index:unread:", JID, "@easemob.com/",Resource, ":", M]),
                                    0,-1]),
                      io:format("queue ~p ~n", [M]),
                      lists:foreach(
                        fun(MID) ->
                                io:format("       MID is ~p~n", [MID]),
                                Meta = (catch msync_msg:decode_meta(message_store:read(MID))),
                                io:format("       BODY is ~p~n", [Meta ])
                        end, List)
              end, Result).
