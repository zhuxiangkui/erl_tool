echo(off),

ToTupleList =
    fun Fun([], TupleList) ->
            TupleList;
        Fun([K, V | Rest], TupleList) ->
            Fun(Rest, [{list_to_atom(K), list_to_integer(V)} | TupleList])
    end,

TupleList = ToTupleList(Args, []),
ets:insert(shaper, TupleList).
