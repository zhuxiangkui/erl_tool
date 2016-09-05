
% input: all | sub | muc
%
% op: get store nodes
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_store_nodes.erl all

echo(off),
Type =
case Args of
    [ "all" ] -> all;
    [ "sub" ] -> sub;
    [ "muc" ] -> muc;
    _ ->
        io:format("get_store_nodes.erl [all|sub|muc]\n",[]),
        exit(normal)
end,
try ets:lookup(store_nodes, Type)of
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
