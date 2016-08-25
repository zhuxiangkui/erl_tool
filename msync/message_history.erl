% input: JID
%
% op: load all messages sent/received for the JID
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/message_history.erl

echo(on),
[User0] = Args,
LUser = list_to_binary(User0),
LServer = <<"easemob.com">>,

Username = jlib:jid_to_string(jlib:make_jid(ejabberd_odbc:escape(LUser), LServer, <<"mobile">>)),
MessageIndexList =
case catch easemob_odbc:sql_shard_query(<<"odbc_shards">>,  Username,
                                         [<<"select mid, timestamp, type, opposite from message_index_">>,
                                          odbc_queries:get_table_number(Username),
                                          <<"  where username='">>,
                                          Username, <<"'  order by timestamp desc;">>])
of
    {selected, _R1, Rs} ->
        lists:flatmap(fun (R) ->
                              case R of
                                  [Mid, Timestamp, <<"s">>, Opposite] ->
                                      [[Mid, Timestamp, <<"sent">>, Opposite]];
                                  [Mid, Timestamp, <<"r">>, Opposite] ->
                                      [[Mid, Timestamp, <<"received">>, Opposite]];
                                  _ -> []
                              end
                      end,
                      Rs);
    Reason ->
        []
end,


lists:foreach(
  fun([Mid, Timestamp, Dir, Opposite]) ->
	  io:format("~s\t~s\t~s\t~s~n",[Mid, Timestamp, Dir, Opposite])
  end, MessageIndexList).
