% input: Muc
%
% op: get Muc members
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/get_group_members.erl easemob-demo#chatdemoui_1492069834887
%		Input Muc Room like easemob-demo#chatdemoui_group1
%		members in cache:[{<<"easemob-demo#chatdemoui_na1">>,<<"easemob.com">>,owner,
%                   <<>>},
%                  {<<"easemob-demo#chatdemoui_na3">>,<<"easemob.com">>,member,
%                   <<>>},
%                  {<<"easemob-demo#chatdemoui_na2">>,<<"easemob.com">>,member,
%                   <<>>}] 
% 		Members num :3 
%		members in DB:[{<<"easemob-demo#chatdemoui_na3">>,<<"easemob.com">>,member,
%                <<>>},
%               {<<"easemob-demo#chatdemoui_na1">>,<<"easemob.com">>,owner,
%                <<>>},
%               {<<"easemob-demo#chatdemoui_na2">>,<<"easemob.com">>,member,
%                <<>>}] 
% 		Members num :3 

echo(off),
io:format("Input Muc Room like easemob-demo#chatdemoui_group1~n", []),
[MucList] = Args,
Muc = list_to_binary(MucList),
MembersInCache = mod_muc_admin:get_room_affiliations(Muc, <<"conference.easemob.com">>),
io:format("members in cache:~p ~n Members num :~p ~n", [MembersInCache, erlang:length(MembersInCache)]),
MembersInDB = mod_easemob_cache:get_group_affiliations(<<"easemob.com">>, Muc),
io:format("members in DB:~p ~n Members num :~p ~n", [MembersInDB, erlang:length(MembersInDB)]).
