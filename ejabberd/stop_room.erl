echo(off),
[GroupId] = Args,
mod_muc_admin:stop_room(list_to_binary(GroupId), <<"conference.easemob.com">>, any),
ok.
