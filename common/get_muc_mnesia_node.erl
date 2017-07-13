%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/get_muc_mnesia_node.erl
%%
echo(off),
Node = ejabberd_store:random_store_node(muc), 
case catch rpc:call(Node, mnesia, system_info, [running_db_nodes]) of
    {'EXIT', Error} ->
        io:format("Error:~p ~n", [Error]),
        exit(1);
    Result ->
        io:format("Muc Mnesia List ~p ~n", [Result])
end.
