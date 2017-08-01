% input:
% 1 mid
% 2 mid to
%
% op: get msg track from ssdb
%
% e.g.: ./erl_expect -sname ejabberd@localhost -setcookie 'ejabberd'  common/get_msg_track_ssdb.erl 360803687796310844
%     "{\"timestamp\":1501570954905,\"chat_type\":\"\",\"direction\":\"ack\",\"from\":\"easemob-demo#chatdemoui_na2@easemob.com\",\"to\":\"easemob-demo#chatdemoui_na1@easemob.com\",\"payload\":\"\",
%      \"msg_id\":\"360803687796310844\"}"

echo(off),

case Args of
    [Mid] ->
	{ok, TrackList} = easemob_message_log_ssdb:read_message_log_ssdb(erlang:list_to_binary(Mid)),
	lists:foreach(fun (MsgTrack) -> io:format("~p~n", [erlang:binary_to_list(MsgTrack)]) end, TrackList);
    [Mid, To] ->
	{ok, TrackList} = easemob_message_log_ssdb:read_message_log_ssdb(erlang:list_to_binary(Mid)),
	TrackList_to = [jsx:decode(V) || V <- TrackList],
	TrackList_to1 = lists:filter(fun ([_,_,_,_,{<<"to">>, To_Ele},_,_]) -> erlang:list_to_binary(To) == To_Ele end, TrackList_to),
	TrackList_to2 =[jsx:encode(V) || V <- TrackList_to1],
	lists:foreach(fun (MsgTrack) -> io:format("~p~n", [erlang:binary_to_list(MsgTrack)]) end, TrackList_to2)
end. 
	    
