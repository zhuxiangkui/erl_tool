echo(off),
{Type, Nodes}  =
case Args of
    [ "all" | Args2 ] ->
        {all, lists:map(fun(X) -> list_to_atom(X) end, Args2)};
    [ "sub" | Args2 ] ->
        {sub, lists:map(fun(X) -> list_to_atom(X) end, Args2)};
    [ "muc" | Args2 ] ->
        {muc, lists:map(fun(X) -> list_to_atom(X) end, Args2)};
    _ ->
        io:format("set_store_nodes.erl [all|sub|muc] <Node0> <Node1> ....\n",[]),
        exit(normal)
end,
IsNodeAlive =
fun(Node) ->
        try net_adm:ping(Node) of
            pong ->
                true;
            _ ->
                false
        catch
            _:_ -> false
        end
end,
{AliveNodes, DeadNodes} = lists:partition(IsNodeAlive, Nodes),

case DeadNodes of
    [] ->
        ok;
    _ ->
        io:format("warning: these nodes are not reachable:~w~n",[DeadNodes])
end,

X0 = ejabberd_store:set_store_nodes(Type, AliveNodes),
io:format("ejabberd_store:set_store_nodes => ~w~n", [X0]),

NodeResults = ets:lookup(store_nodes, Type),
io:format("nodes: ~w~n",[NodeResults]),

ok.
