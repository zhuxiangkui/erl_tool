echo(off),
case Args of
    [RawAppKey, RawGroupID, RawMID] ->
        AppKey = list_to_binary(RawAppKey),
        GroupID = list_to_binary(RawGroupID),
        GroupName = <<AppKey/binary, "_", GroupID/binary>>,
        GroupDomain = <<AppKey/binary, "_", GroupID/binary, "@conference.easemob.com">>,
        MID = list_to_binary(RawMID),
        try easemob_muc_redis:read_group_affiliations(GroupName) of
            Members ->
                [<<M/binary, "@easemob.com">> || M <- Members],
                lists:foreach(fun (Member) ->
                                      UserDomainResList =
                                          easemob_resource:get_users_list([Member]),
                                      easemob_user_cursor:set_cursors(
                                        [Member], GroupName, <<"0">>)
                              end, Members),
                io:format("init ok~n", [])
        catch Class: Reason ->
                io:format("read group members failed, class: ~p, reason: ~p",
                          [Class, Reason])
        end;
    [RawAppKey, RawGroupID, RawUserName, RawMID] ->
        AppKey = list_to_binary(RawAppKey),
        GroupID = list_to_binary(RawGroupID),
        UserName = list_to_binary(RawUserName),
        GroupName = <<AppKey/binary, "_", GroupID/binary, "@conference.easemob.com">>,
        UserDomain = <<AppKey/binary, "_", UserName/binary, "@easemob.com">>,
        UserDomainResList = easemob_resource:get_users_list([UserDomain]),
        MID = list_to_binary(RawMID),
        easemob_user_cursor:set_cursors(UserDomainResList, GroupName, MID),
        io:format("init ok~n", []);
    _ ->
        io:format("wrong args~n", [])
end,
ok.
