echo(off),
EtcdClient =
    {ejabberd_etcd_client,
     {ejabberd_etcd_client, start_link, []},
     permanent,
     brutal_kill,
     worker,
     [ejabberd_etcd_client]},
case erlang:whereis(ejabberd_etcd_client) of
    Pid when erlang:is_pid(Pid) ->
        ok;
    _ ->
        supervisor:start_child(ejabberd_sup, EtcdClient)
end,
ejabberd_etcd_register:enable_etcd_service_disc(),
ok.
