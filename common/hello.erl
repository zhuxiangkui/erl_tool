
% input: none
%
% op: check whether the node is ok
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/hello.erl

io:format("hello world from ~p~n",[node()]).
