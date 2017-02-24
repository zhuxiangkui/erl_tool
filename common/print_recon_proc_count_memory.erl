echo(off),
io:format("~p~n", [[{X/1024/1024, recon:info(P)} || {P, X, _} <-  recon:proc_count(memory, 3)]]),
io:format("~p~n", [recon_alloc:memory(usage)]),
ok.

