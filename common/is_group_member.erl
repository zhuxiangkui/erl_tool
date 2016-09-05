
% input: Muc, Jid
%
% op: whether Jid is one member of Muc
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/is_group_member.erl Muc Jid

echo(off),
io:format("Input Muc Room like easemob-demo#chatdemoui_group1 Member like easemob-demo#chatdemoui_mt001 ~n", []),
[MucArgs, MemberArgs] = Args,
Muc = list_to_binary(MucArgs),
Member = list_to_binary(MemberArgs),
Ret = mod_easemob_cache:is_group_affiliation(<<"easemob.com">>, Muc, Member),
io:format("Muc:~p Member:~p Result:~p ~n", [Muc, Member, Ret]).
