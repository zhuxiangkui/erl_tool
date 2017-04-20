% input: JID
%
% op: get roster for given JID
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/read_roster.erl easemob-demo#chatdemoui_na1
%		rosters: [{roster,{<<"easemob-demo#chatdemoui_na1">>,<<"easemob.com">>,
%                   {<<"easemob-demo#chatdemoui_na2">>,<<"easemob.com">>,<<>>}},
%                 {<<"easemob-demo#chatdemoui_na1">>,<<"easemob.com">>},
%                 {<<"easemob-demo#chatdemoui_na2">>,<<"easemob.com">>,<<>>},
%                 <<>>,both,none,[],<<>>,[]},
%				  ...

echo(off),
[JID] = Args,
%io:format("JID~p ~n", [JID]),
io:format("rosters: ~p~n", [mod_roster:get_roster(list_to_binary(JID), <<"easemob.com">>)]).
