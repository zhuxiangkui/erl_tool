echo(off),

GetTopics =
fun(Key) ->
        Host = <<"easemob.com">>,
        Module = mod_easemob_sendmsg,
        gen_mod:get_module_opt(Host, Module, Key,
                           fun(Topics) ->
                                   F = fun(V) -> iolist_to_binary(V) end,
                                   [F(S) || S <- Topics]
                           end, [])
end,


GetTopicNames  =
fun(Topics, NamePreffix) ->
        lists:map(
          fun(Topic) ->
                  Host = <<"easemob.com">>,
                  Name = gen_mod:get_module_proc(Host, NamePreffix),
                  binary_to_atom(<<(erlang:atom_to_binary(Name, latin1))/binary, "_", Topic/binary>>, latin1)
          end, Topics)
end,

Names = GetTopicNames(GetTopics(redis_chat_topic), ejabberd_easemob_sendmsg),
GroupNames = GetTopicNames(GetTopics(redis_groupchat_topic), ejabberd_easemob_group_sendmsg),

AllNames = Names ++ GroupNames,

lists:foreach(
  fun(N) ->
          io:format("~s is alive ~p~n", [N, whereis(N)])
  end, AllNames),
ok.
