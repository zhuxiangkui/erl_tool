%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/reset_store_nodes.erl
%%
echo(on),
NodeGroup = store_nodes,
Bin2Atom = fun(L) -> [binary_to_atom(iolist_to_binary(T), latin1) || T <- L] end,
NodesFun = fun(NN) -> [{Name, Bin2Atom(Nodes)} || {Name, Nodes} <- NN] end,
NodesConfig = ejabberd_config:get_option(NodeGroup, NodesFun, []),
[ejabberd_node:set_nodes(NodeGroup, Name, Nodes) || {Name, Nodes} <- NodesConfig],
ok.
