% input: normal, value, rest, value, ...
%
% op: set shaper param values for msync
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/set_shaper.erl normal 2000 rest 2000


echo(off),

ToTupleList =
    fun Fun([], TupleList) ->
            TupleList;
        Fun([K, V | Rest], TupleList) ->
            Fun(Rest, [{list_to_atom(K), list_to_integer(V)} | TupleList])
    end,

TupleList = ToTupleList(Args, []),
ets:insert(shaper, TupleList).
