% input: none
%
% op: stop ejabberd room 
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/stop_room.erl

echo(off),
[GroupId] = Args,
mod_muc_admin:stop_room(list_to_binary(GroupId), <<"conference.easemob.com">>, any),
ok.
