
% input: ID
%
% op: get time info from ID
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/explain_id.erl ID

echo(off),
[ID0] = Args,
Id = list_to_integer(ID0),


IDS = ticktick_id:explain(binary:encode_unsigned(Id)),

Timestamp = proplists:get_value(seconds, IDS) + 1417564800,

Cmd = ["date -d@" ++ integer_to_list(Timestamp)],
io:format("~s~n", [Cmd]),

io:format("~s: ~p~n", [os:cmd(Cmd), IDS]),

ok.
