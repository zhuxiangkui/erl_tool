% input: none
%
% op: stop muc room in this node 
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/stop_muc_rooms_on_this_node.erl

echo(on),
muc_mnesia:rpc_clean_table_from_bad_node(node()),
ok.
