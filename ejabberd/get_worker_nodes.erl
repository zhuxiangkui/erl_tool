echo(off),
Type =
case Args of
    [ "all" ] -> all;
    [ "sub" ] -> sub;
    _ ->
        io:format("get_worker_nodes.erl [all|sub]\n",[]),
        exit(normal)
end,
try ets:lookup(worker_nodes, Type)of
    [{_,_,NodeResults}]->
        lists:foreach(
          fun(Node) ->
                  io:format("~w ",[Node])
          end, NodeResults),
        io:format("~n",[]);
    [] ->
        io:format("error no nodes~n",[])
catch
    E:V ->
        io:format("error ~w:~w~n",[E,V])
end,

ok.
