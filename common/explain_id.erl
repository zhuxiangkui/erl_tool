% input: ID
%
% op: get time info from ID
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/explain_id.erl 320353223237960508
%       date -d@1492152847
%	    Fri Apr 14 06:54:07 UTC 2017
%		: [{version,0},
%  		{seconds,74588047},
%   	{mseconds,167},
%   	{sequence,0},
%   	{machine,207},
%   	{tag,0}]

echo(off),
[ID0] = Args,
Id = list_to_integer(ID0),


IDS = ticktick_id:explain(binary:encode_unsigned(Id)),

Timestamp = proplists:get_value(seconds, IDS) + 1417564800,

Cmd = ["date -d@" ++ integer_to_list(Timestamp)],
io:format("~s~n", [Cmd]),

io:format("~s: ~p~n", [os:cmd(Cmd), IDS]),

ok.
