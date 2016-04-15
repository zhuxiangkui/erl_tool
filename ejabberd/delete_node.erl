[NodeName0] = Args,
NodeName = list_to_atom(NodeName0),
mnesia:del_table_copy(schema, NodeName).
