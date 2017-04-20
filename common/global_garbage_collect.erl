% input: none
%
% op: garbage collect for all processes
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/global_garbage_collect.erl
%
echo(off),
io:format(" time : ~p, gc ~p~n", [erlang:localtime(), recon:bin_leak(10)]),
ok.
