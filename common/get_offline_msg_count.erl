[JID,Resource] = case Args of
                     [ID] ->
                         [list_to_binary(ID), <<"mobile">>];
                     [ID, R] ->
                         [list_to_binary(ID), list_to_binary(R)]
                 end,
mod_message_index_cache:read_offline_message([], JID, <<"easemob.com">>, <<"">>),

Worker = cuesport:get_worker(index),
{ok, Result} = eredis:q(Worker, [hgetall, iolist_to_binary(["unread:", JID , "@easemob.com/", Resource])]),
List2PlistFun =
fun List2Plist([], Acc) ->
	lists:reverse(Acc);
    List2Plist([K], Acc) ->
	lists:reverse([{K,undefined} | Acc]);
    List2Plist([K,V|T], Acc) ->
	List2Plist(T, [{K,V} | Acc])
end,

Total =
lists:foldl(
  fun
      ({<<"_total">>, Nstr}, AccInner) ->
	  AccInner;
      ({Queue, Nstr}, AccInner) ->
	  Query = [lrange, iolist_to_binary(["index:unread:", JID, "@easemob.com/",Resource, ":", Queue]), 0,-1],
	  case eredis:q(Worker,Query) of
	      {ok, List} ->
		  AccInner + erlang:length(List);
	      W ->
		  AccInner
	  end;
      (W,AccInner) ->
	  AccInner
  end, 0, List2PlistFun(Result,[])),
io:format("~s has ~p offline message(s)~n",[JID, Total]),
ok.
