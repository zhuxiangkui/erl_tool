% input: JID
%
% op: get each session of multi resource for JID
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/get_user_sessions.erl easemob-demo#chatdemoui_na1
%		 "2017-04-20T04:12:58": Pid = <8522.17823.0>(true), Node = 'ejabberd@ejabberd-conn' Priority = 0 Resource = <<"mobile">>

echo(off),
[JID] =  Args,
User = list_to_binary(JID),
Server = <<"easemob.com">>,
IsProcessAlive = 
fun (Process) ->
	rpc:call(node(Process), erlang, is_process_alive, [Process])
end,

    
Ret = lists:map(fun(R) ->
			Session = ejabberd_sm:get_session(User, Server, R),
			    case Session of
				[{session,_,{Ts, Pid}, _, Priority, _}] when is_pid(Pid) ->
				    {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:now_to_datetime(Ts),
				    StrTime = lists:flatten(io_lib:format("~4..0w-~2..0w-~2..0wT~2..0w:~2..0w:~2..0w",[Year,Month,Day,Hour,Minute,Second])),
				    io:format("~p: Pid = ~p(~p), Node = ~p Priority = ~p Resource = ~p~n", [StrTime, Pid, IsProcessAlive(Pid), node(Pid), Priority, R]);
				[{session,_,{_, {msync_c2s, Node}}, _, _, Info}] ->
				    io:format("Socket = ~p, Node = ~p~n", [proplists:get_value(socket, Info, undefined),Node]);
				_ ->
				    ok
			    end
		end,
	        ejabberd_sm:get_user_resources(User, Server)),
ok.
