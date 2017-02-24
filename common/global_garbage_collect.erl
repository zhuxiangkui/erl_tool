echo(off),
io:format(" time : ~p, gc ~p~n", [erlang:localtime(), recon:bin_leak(10)]),
ok.
