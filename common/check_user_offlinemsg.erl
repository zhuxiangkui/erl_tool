io:format("User~p ~n", [Args]),

[File, Out]  = Args,

{ok, UserMIDs} = file:consult(File),

Result = lists:map(fun({U, MIDs}) ->
                           JID = <<U/binary, "@easemob.com">>,
                           [_ShardNumbers, TableNumber] = config_odbc_shards:shard_info(JID),
                           IndexSql = [<<"select mid from message_index_">>, erlang:integer_to_binary(TableNumber),
                                       <<" where username = '">>, JID, <<"' and type = \"r\" order by id desc limit ">>,
                                       erlang:integer_to_binary(3000), <<";">>],
                           Rets =
                               case catch easemob_odbc:sql_shard_query(<<"odbc_shards">>, JID, IndexSql) of
                                   {selected, [<<"mid">>], MIds} ->
                                       lists:reverse(lists:flatten(MIds));
                                   Reason ->
                                       []
                               end,
                           {U, MIDs -- Rets}
                   end, UserMIDs),

{ok, IO} = file:open(Out, [write]),
lists:foreach(fun({User, MIds}) ->
                      Format = lists:concat(lists:duplicate(erlang:length(MIds), "~p ~p~n")),
                      Users = lists:flatmap(fun(MId) -> [User, MId] end, MIds),
                      io:format(IO, Format,Users)
              end, Result),
ok.
