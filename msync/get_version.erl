echo(off),
[User] = Args,
BJid = list_to_binary(User),
{Version, Ip} = case ejabberd_sm:get_session(BJid, <<"easemob.com">>, <<"mobile">>) of
            [{session, _, _, _, _, [{ip, {{P1, P2, P3, P4}, Port}}, _,  {_, Sock1}, _]}] ->
                case msync_c2s_lib:get_socket_prop(Sock1, version) of
                    {ok, V} ->
                        IpPort = binary_to_atom(iolist_to_binary(io_lib:format("~p.~p.~p.~p:~p", [P1, P2, P3, P4, Port])), latin1),
                        {V, IpPort};
                    _ -> {version_not_found, not_found}
                end;
            _ -> {session_not_found, not_found}
          end,
io:format("node: ~p  user: ~p client version: ~p  ip:port ~p~n", [node(), User, Version, Ip]).
