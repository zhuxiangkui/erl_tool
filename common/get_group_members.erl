echo(off),
io:format("Input Muc Room like easemob-demo#chatdemoui_group1~n", []),
[MucList] = Args,
Muc = list_to_binary(MucList),
MembersInCache = mod_muc_admin:get_room_affiliations(Muc, <<"conference.easemob.com">>),
io:format("members in cache:~p ~n Members num :~p ~n", [MembersInCache, erlang:length(MembersInCache)]),
MembersInDB = mod_easemob_cache:get_group_affiliations(<<"easemob.com">>, Muc),
io:format("members in DB:~p ~n Members num :~p ~n", [MembersInDB, erlang:length(MembersInDB)]).
