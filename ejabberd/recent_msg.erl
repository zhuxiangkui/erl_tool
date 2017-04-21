% input: JID
%
% op: load all messages sent/received for the JID
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd' ejabberd/recent_msg.erl easemob-demo#chatdemoui_na3
%		322541702495601276	<message from='easemob-demo#chatdemoui_na1@easemob.com' to='easemob-demo#chatdemoui_1492069834887@conference.easemob.com' id='322541702495601276' type='groupchat'><body>{&quot;from&quot;:&quot;na1&quot;,&quot;to&quot;:&quot;1492069834887&quot;,&quot;bodies&quot;:[{&quot;type&quot;:&quot;txt&quot;,&quot;msg&quot;:&quot;aasd&quot;}],&quot;ext&quot;:{}}</body><delay xmlns='urn:xmpp:delay' stamp='2017-04-20T04:26:32.204Z'/></message>
%		...
%
% note:store index in mysql is cancel so just get offline msg

echo(off),
[User0] = Args,
User = list_to_binary(User0),

MidList =
lists:filtermap(
  fun([Mid1, _Timestamp, <<"received">>, _Opposite]) ->
	  {true, Mid1};
     (_) ->
	  false
  end, mod_message_store:load_message_index(User, <<"easemob.com">>)),
UnreadList = 
easemob_offline_index:get_messages_index(<<User/binary, "@easemob.com/mobile">>),
UnreadMidList =
lists:map(fun({_, MID}) -> MID end, UnreadList),
SortMidList = 
   lists:sort(fun(A, B) ->
                       erlang:binary_to_integer(A) > erlang:binary_to_integer(B)
	      end, UnreadMidList ++ lists:sublist(MidList, 200)),

lists:foreach(fun({Mid, B}) ->
		  Size = erlang:byte_size(B),
		  case Size >= 65530  of
		      true ->
			  io:format("~s\tnot_found~n",[Mid]);
		      false ->
			  case B of
			      <<"<", _/binary>> ->
				  io:format("~s\t~s~n",[Mid, B]);
			      _ ->
				  Meta = msync_msg:decode_meta(B),
				  io:format("~s\t~p~n",[Mid, Meta])
			  end
		  end
	  end, lists:zip(SortMidList, easemob_message_body:read_messages(SortMidList))),

ok.
