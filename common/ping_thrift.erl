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
                      case catch sys:get_state(whereis(P)) of
                          {_, _, Workers, _} ->
                              queue:to_list(Workers);
                          Exception ->
                              io:format("Node:~p P:~p Exception:~p ~n", [node(), P, Exception]),
                              []
                      end
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
        io:format("~n Node:~p every client is all right ~p available rate ~p % ~n", [node(), erlang:length(Clients), 100]);
    false ->
        FailedLen = erlang:length(Ret),
        AllLen = erlang:length(Clients),
        io:format("~n Node:~p Failed ~p All clients is ~p AvailableRate ~p % ~n", [node(), FailedLen, AllLen, (AllLen - FailedLen) / AllLen * 100])
end,
ok.
