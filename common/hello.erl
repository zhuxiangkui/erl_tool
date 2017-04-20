% input: none
%
% op: check whether the node is ok
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/hello.erl
%		hello world from 'ejabberd@ejabberd-worker'

io:format("hello world from ~p~n",[node()]).
