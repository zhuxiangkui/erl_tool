echo(on),
case  ejkaf_server:is_node_alive() of
    true ->
        ok;
    false ->
        ejkaf_server:start_java_node()
end,
timer:sleep(1000),

migrate_offline:start_incr(),
ok.
