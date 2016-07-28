
% input: JID
%
% op: get offline msg number for JID
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_offline_msg_count.erl JID

[JID,Resource] = case Args of
                     [ID] ->
                         [list_to_binary(ID), <<"mobile">>];
                     [ID, R] ->
                         [list_to_binary(ID), list_to_binary(R)]
                 end,

mod_message_index_cache:read_offline_message([], JID, <<"easemob.com">>, <<"">>),

Worker = cuesport:get_worker(index),

List2PlistFun =
    fun List2Plist([], Acc) ->
	    lists:reverse(Acc);
    List2Plist([K], Acc) ->
	    lists:reverse([{K,undefined} | Acc]);
    List2Plist([K,V|T], Acc) ->
	    List2Plist(T, [{K,V} | Acc])
    end,

TotalListFun = 
    fun() ->
        {ok, Result} = eredis:q(Worker, [hgetall, iolist_to_binary(["unread:", JID , "@easemob.com/", Resource])]),
        TotalList = lists:foldl(
            fun({<<"_total">>, Nstr}, AccInner) ->
                AccInner;
            ({Queue, Nstr}, AccInner) ->
                Query = [lrange, iolist_to_binary(["index:unread:", JID, "@easemob.com/",Resource, ":", Queue]), 0,-1],
                case eredis:q(Worker,Query) of
                    {ok, List} ->
                        lists:append(List, AccInner);
                    W -> AccInner
                end;
            (W,AccInner) ->
                AccInner
            end, [], List2PlistFun(Result,[])),
        TotalList
    end,

TotalList1 = TotalListFun(),

timer:sleep(5000),

TotalList2 = TotalListFun(),

Intersection = TotalList1 -- ( TotalList1 -- TotalList2 ),
case length(Intersection) of
    0 ->
        io:format("~s has ~p offline message(s)~n",[JID, length(Intersection)]);
    _ ->
        Session = ejabberd_sm:get_session(JID, <<"easemob.com">>, Resource),
        case Session of
            [{session,_,{_, Pid}, _, _, _}] when is_pid(Pid) ->
                io:format("Pid = ~p, Node = ~p~n", [Pid, node(Pid)]);
            [{session,_,{_, {msync_c2s, Node}}, _, _, Info}] ->
                io:format("Socket = ~p, Node = ~p~n", [proplists:get_value(socket, Info, undefined),Node]);
            _ ->
                io:format("~s is not online now~n", [JID]),
                ok
        end,
        io:format("~s has ~p offline message(s)~n",[JID, length(Intersection)]),
        lists:foreach(
            fun(MID) ->
                io:format("    MID is ~p~n", [MID])
            end, Intersection)
end,

ok.
