% input: none
%
% op: get rest machines
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/get_rest_machine.erl
%		Result:['ejabberd@ejabberd-restnormal']	

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
