% input: Muc
%
% op: get Muc online members
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/get_group_online_users.erl easemob-demo#chatdemoui_1492069834887
%		Input Muc Room like easemob-demo#chatdemoui_group1
%		Args:["easemob-demo#chatdemoui_1492069834887"] 
%		muc <<"easemob-demo#chatdemoui_1492069834887">>  online users :[{<<"easemob-demo#chatdemoui_na1">>,
%		...

echo(off),
io:format("Input Muc Room like easemob-demo#chatdemoui_group1~n Args:~p ~n", [Args]),
[MucArgs] = Args,
Muc = list_to_binary(MucArgs),
Members = mod_muc_admin:get_room_affiliations(Muc, <<"conference.easemob.com">>),
OnlineUsers =
lists:filtermap(fun({U, S, _, _}) ->
                        Session = ejabberd_sm:get_user_resources(U, S),
                        Session =/= []
                end, Members),
io:format("muc ~p  online users :~p ~n", [Muc, OnlineUsers]).
