
% input: none
%
% op: get overload for msync
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/get_overload.erl

application:get_env(msync, overload, 2000).
