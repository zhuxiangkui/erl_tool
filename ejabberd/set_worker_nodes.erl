% input: [all | sub | muc] ++ NodeList
%
% op: for ejabberd
%    1) enable blackhole mode, or restore from blackhole
%    2) could also check which nodes not response to ping
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/set_worker_nodes.erl all ejabberd@sdb-ali-hangzhou-ejabberd2

echo(off),
{Type, Nodes}  =
case Args of
    [ "all" | Args2 ] ->
        {all, lists:map(fun(X) -> list_to_atom(X) end, Args2)};
    [ "sub" | Args2 ] ->
        {sub, lists:map(fun(X) -> list_to_atom(X) end, Args2)};
    _ ->
        io:format("set_worker_nodes.erl [all|sub] <Node0> <Node1> ....\n",[]),
        exit(normal)
end,
IsNodeAlive =
fun(Node) ->
        try net_adm:ping(Node) of
            pong ->
                try rpc:call(Node, erlang, node, []) of
                    Node -> true;
                    _ -> false
                catch
                    _:_ -> false
                end;
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

X0 = ejabberd_worker:set_worker_nodes(Type, AliveNodes),
case AliveNodes of
    [] ->
        io:format("clear all worker nodes => ~w~n", [X0]);
    _ ->
        io:format("set worker nodes => ~w~n", [X0])
end,

try ets:lookup(worker_nodes, Type)of
    [{_,_,NodeResults}]->
        lists:foreach(
          fun(Node) ->
                  io:format("~w ",[Node])
          end, NodeResults),
        io:format("~n",[]);
    [] ->
        io:format("black mode is enabled.~n",[])
catch
    E:V ->
        io:format("error ~w:~w~n",[E,V])
end,

ok.
