
%% input: JID
%%
%% op: get roster for given JID
%%
%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/read_roster.erl JID

echo(off),
[JID] = Args,
%io:format("JID~p ~n", [JID]),
io:format("rosters: ~p~n", [mod_roster:get_roster(list_to_binary(JID), <<"easemob.com">>)]).
