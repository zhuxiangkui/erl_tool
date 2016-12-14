
%% input: resource key
%%
%% op: clean expired resource
%%
%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/clean_resource.erl ResKey
%%
%% for example,
%% ResKey = im:resource:xizi#xiziquan_2021292@easemob.com

[Eid0] = [Args],
Eid = case list_to_binary(Eid0) of
    <<"im:resource:", Eid1/binary>> ->
        Eid1;
    _ ->
        io:format("wrong usage~n")
end,

easemob_resource:try_clear_expired_resource(Eid).

