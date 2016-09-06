
% input: node
%
% op: get mnesia nodes
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_mnesia_nodes.erl

echo(off),
Nodes = mnesia:table_info(schema, all_nodes) -- [node()],
io:format("Mnesia Nodes:~p ~n", [Nodes]),
ok.
