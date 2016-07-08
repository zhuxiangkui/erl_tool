echo(off),
BArgs = lists:map(fun(A) -> list_to_binary(A) end, Args),
[GID | Members] = BArgs,
Server = <<"easemob.com">>,
Owner = mod_easemob_cache:get_group_owner(Server, GID),
Affs = lists:map(fun(M) -> {M, Server, member, <<>>} end, Members -- [Owner]),
Type = mod_easemob_cache_query_cmd:get_group_type(GID),
mod_easemob_cache:add_group_affiliations(Type, Server, GID, [{Owner, Server, owner, <<>>} | Affs]),
mod_muc_admin:stop_room(GID, <<"conference.easemob.com">>, any).
