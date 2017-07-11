%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/reload_worker_nodes.erl
%%
echo(off),
NodeGroup = worker_nodes,
Bin2Atom = fun(L) -> [binary_to_atom(iolist_to_binary(T), latin1) || T <- L] end,
NodesFun = fun(NN) -> [{Name, Bin2Atom(Nodes)} || {Name, Nodes} <- NN] end,
NodesConfig = ejabberd_config:get_option(NodeGroup, NodesFun, []),
ejabberd_node:set_retry_times(NodeGroup, 2),
[ejabberd_node:set_nodes(NodeGroup, Name, Nodes) || {Name, Nodes} <- NodesConfig],
ok.
