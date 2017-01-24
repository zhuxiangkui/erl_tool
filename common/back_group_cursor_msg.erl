%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/back_group_cursor_msg.erl
%%
%%%     1. get members of cursor group
%%%     2. get users' resources
%%%     3. get users' resources's msgid list
%%%     4. lpush the msg into index
echo(off),
[GroupIDList] = Args,
GroupID = list_to_binary(GroupIDList),

GetGroupsMembers =
fun(GroupID) ->
        Affiliations = mod_easemob_cache:get_group_affiliations(<<"easemob.com">>, GroupID),
        lists:map(fun({Member, _, _, _}) ->
                          <<Member/binary, "@easemob.com">>
                  end, Affiliations)
end,

GetUsersRes =
fun(UserDomains) ->
        UsersDomainResList = easemob_resource:get_users_resources(UserDomains),
        lists:flatmap(
          fun({UserDomain, UserDomainResList}) ->
                  lists:map(
                    fun(Res) ->
                            utils:get_resource_eid(UserDomain, Res)
                    end,UserDomainResList)
          end, lists:zip(UserDomains, UsersDomainResList))
end,

GetUsersMsgIDList =
fun(UserDomainResList, CID, GroupMsgList) ->
        lists:map(fun(UserDomainRes) ->
                          CurMID = easemob_user_cursor:get_cursor(UserDomainRes, CID),
                          MIDList = utils:get_list_after_value(GroupMsgList, CurMID, GroupMsgList),
                          {UserDomainRes, MIDList}
                  end, UserDomainResList)
end,

MakePushQueries =
fun(UserDomainResAndMIDList, GroupDomain) ->
        lists:flatmap(
          fun({UserDomainRes, MIDList}) ->
                  IndexKey = easemob_offline_index:get_index_key(UserDomainRes, GroupDomain),
                  lists:map(
                    fun(MID) ->
                            ["LPUSH", IndexKey] ++ MIDList
                    end, MIDList)
          end, UserDomainResAndMIDList)
end,

%% add domain to groups
MembersList = GetGroupsMembers(GroupID),
UsersDomainResList = GetUsersRes(MembersList),
%% get groups' msglist
GroupDomain = <<GroupID/binary, "@conference.easemob.com">>,
[GroupsMsgList] = easemob_group_msg_cursor:read_groups_msg_indice([GroupDomain], 200),
%% get users' groups' msglist
UsersMIDList = GetUsersMsgIDList(UsersDomainResList, GroupDomain, GroupsMsgList),
%% make queries and filter null
Queries = MakePushQueries(UsersMIDList, GroupDomain),
WithOutNull = lists:filter(fun(Q) -> Q /= [] end, Queries),
easemob_redis:qp(index, WithOutNull),
ok.
