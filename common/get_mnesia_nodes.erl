% input: node
%
% op: get mnesia nodes
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/get_mnesia_nodes.erl 
%       Mnesia Nodes:[]

echo(off),
Nodes = mnesia:table_info(schema, all_nodes) -- [node()],
io:format("Mnesia Nodes:~p ~n", [Nodes]),
ok.
