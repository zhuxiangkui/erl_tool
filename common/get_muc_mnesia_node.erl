%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/get_muc_mnesia_node.erl
%%
echo(off),
Node = ejabberd_store:random_store_node(muc), 
case recon:named_rpc(Node, fun() -> mnesia:system_info(running_db_nodes) end, 5000) of
    {[{_, Result}], []} ->
        io:format("Muc Mnesia List ~p ~n", [Result]);
    Error ->
        io:format("Error:~p ~n", [Error]),
        exit(1)
end.
