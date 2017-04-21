% input: nodenames
%
% op: delete node
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/delete_node.erl ejabberd@ejabberd-worker

[NodeName0] = Args,
NodeName = list_to_atom(NodeName0),
mnesia:del_table_copy(schema, NodeName).
