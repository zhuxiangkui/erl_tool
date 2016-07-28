
% input: none
%
% op: get msync user_auth_module, msync_user or msync_user_with_poolboy 
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/get_auth_module.erl

echo(off),
Module = application:get_env(msync, user_auth_module, msync_user),
io:format("auth module = ~p~n",[Module]),
ok.
