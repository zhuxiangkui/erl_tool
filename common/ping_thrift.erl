% input: none
%
% op: measure redis visit time
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/ping_thrift.erl

echo(off),

PoolSize = extauth_rpc:extauth_opts(<<"easemob.com">>, pool_size),
Processes =
lists:map(fun(Index) ->
                  gen_mod:get_module_proc(iolist_to_binary([<<"easemob.com">>, integer_to_list(Index)]), eauth)
          end, lists:seq(0,PoolSize - 1)),

UserAuth = {'UserAuth',{'EID',<<"easemob-demo#chatdemoui">>,<<"mt003">>},<<"asd">>,undefined},
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
                                io:format("thrift Client:~p  exception:~p ~n", [Client, Exception]),
                                {true, Client}
                        end
                end, Clients),
case Ret == [] of
    true ->
        io:format("every client is all right ~p ~n", [erlang:length(Clients)]);
    false ->
        io:format("there are ~p all clients is ~p ~n", [erlang:length(Ret), erlang:length(Clients)])
end,
ok.
