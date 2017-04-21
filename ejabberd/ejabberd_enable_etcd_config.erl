% input: none
%
% op: enable etcd configure management feature on ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-88 -setcookie secret ejabberd/ejabberd_enable_etcd_config.erl

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
        case supervisor:start_child(ejabberd_sup, EtcdClient) of
            {error, already_present} ->
                supervisor:restart_child(ejabberd_sup, ejabberd_etcd_client),
                ok;
            {error, {already_started, _}} ->
                ok;
            {ok, _, _} ->
                ok;
            {ok, _} ->
                ok
        end
end,
true = erlang:is_pid(erlang:whereis(ejabberd_etcd_client)),
ok = ejabberd_etcd_config:enable_etcd_config(),
ok.
