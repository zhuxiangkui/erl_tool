
% input: integer()
%
% op: set overload for msync
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/set_overload.erl 500

application:set_env(msync, overload, 2000).
