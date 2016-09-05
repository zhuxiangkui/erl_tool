echo(off),
Nodes = nodes(),
Result =
lists:filtermap(fun(Node) ->
                        Ret = rpc:call(Node, mod_easemob_sendmsg, status, [<<"easemob.com">>], 1000),
                        case Ret of
                            {'EXIT', _} -> false;
                            {badrpc,_} -> false;
                            _ -> true
                        end
                end, Nodes),
io:format("Result:~p ~n", [Result]).
