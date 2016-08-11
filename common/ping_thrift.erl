% input: none
%
% op: measure redis visit time
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/ping_thrift.erl

echo(off),
LogException =
case Args of
    [] ->
        false;
    ["true"] ->
        true
end,

PoolSize = extauth_rpc:extauth_opts(<<"easemob.com">>, pool_size),
Processes =
lists:map(fun(Index) ->
                  gen_mod:get_module_proc(iolist_to_binary([<<"easemob.com">>, integer_to_list(Index)]), eauth)
          end, lists:seq(0,PoolSize - 1)),

UserAuth = {'UserAuth',{'EID',<<"easemob-demo#chatdemoui">>,<<"mt001">>},<<"asd">>,undefined},
Clients =
lists:flatmap(fun(P) ->
                      {_, _, Workers, _} = sys:get_state(whereis(P)),
                      queue:to_list(Workers)
              end, Processes),
Ret =
lists:filtermap(fun(Client) ->
                        {_, Res} = (catch thrift_client:call(Client, login, [UserAuth])),
                        case Res of
                            {ok, _} ->
                                false;
                            Exception ->
                                case LogException of
                                    true ->
                                        io:format("thrift Client:~p  exception:~p ~n", [Client, Exception]);
                                    false ->
                                        ignore
                                end,
                                {true, Client}
                        end
                end, Clients),
case Ret == [] of
    true ->
        io:format("Node:~p every client is all right ~p ~n", [node(), erlang:length(Clients)]);
    false ->
        io:format("Node:~p there are ~p all clients is ~p ~n", [node(), erlang:length(Ret), erlang:length(Clients)])
end,
ok.
