
% input: Len
%
% op: kill process whose message_queue_len is large than Len
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/kill_kill_jammed_process.erl Len

echo(on),

[Len0] = Args,


Len = list_to_integer(Len0),
CanIKillIt = 
fun (P) ->
    try process_info(P, message_queue_len) of
	{message_queue_len, MLen} ->
	    MLen > Len;
	_ ->
	    false
    catch 
	_:_ ->
	    false
    end
end,

Ps = [ P || P <- processes(), CanIKillIt(P) ],

[ process_info(P, message_queue_len) || P <- Ps],

[ exit(P, kill) || P <- Ps],
ok.
