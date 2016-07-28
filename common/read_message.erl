
% input: MID
%
% op: read msg body according to MID
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/read_message.erl MID

echo(off),
[ID] =  Args ,

B = message_store:read(list_to_binary(ID)),

Size = erlang:byte_size(B),
case Size >= 65530  of
    true ->
	io:format("message too long ~p ~p~n", [ID, Size]);
    false ->
	case B of
	    <<"<", _/binary>> ->
		io:format("XML = ~s~n", [B]);
	    _ ->
		ok
	end,
	io:format("binary ~p~n", [B]),
	Meta = msync_msg:decode_meta(B),
	io:format("Meta ~p~n", [Meta]),
	msync_msg:encode_meta(Meta)
end,
ok.



