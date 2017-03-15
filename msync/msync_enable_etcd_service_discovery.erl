echo(off),
EtcdClient =
    {msync_etcd_client,
     {msync_etcd_client, start_link, []},
     permanent,
     brutal_kill,
     worker,
     [msync_etcd_client]},
case erlang:whereis(msync_etcd_client) of
    Pid when erlang:is_pid(Pid) ->
        ok;
    _ ->
        case supervisor:start_child(msync_sup, EtcdClient) of
            {error, already_present} ->
                supervisor:restart_child(msync_sup, msync_etcd_client),
                ok;
            {error, {already_started, _}} ->
                ok;
            {ok, _, _} ->
                ok;
            {ok, _} ->
                ok
        end
end,
true = erlang:is_pid(erlang:whereis(msync_etcd_client)),
msync_etcd_register:enable_etcd_service_disc(),
ok.
