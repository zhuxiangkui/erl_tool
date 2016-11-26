echo(off),
[User] = Args,
BJid = list_to_binary(User),
Session = easemob_session:get_session(BJid, <<"easemob.com">>, <<"mobile">>),
{Version, Ip} = case Session of
            {ok, {session, _, _, _, _, Info}} ->
                {{P1, P2, P3, P4}, Port} = proplists:get_value(ip, Info),
                V = case proplists:get_value(client_version, Info) of
                        {_Type, {V1, V2, V3}} -> binary_to_list(iolist_to_binary([integer_to_binary(V1), ".",  integer_to_binary(V2), ".", integer_to_binary(V3)]));
                        _ -> undefined
                    end,
                IpPort = binary_to_atom(iolist_to_binary(io_lib:format("~p.~p.~p.~p:~p", [P1, P2, P3, P4, Port])), latin1),
                {V, IpPort};
            _ -> {session_not_found, not_found}
          end,
io:format("node: ~p  user: ~p client version: ~p  ip:port ~p~n", [node(), User, Version, Ip]).
