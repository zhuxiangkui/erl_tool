
% input: none
%
% op: get session, codis or mnesia
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_session_db_type.erl

echo(off),
Type = application:get_env(ejabberd, session_db_type, mnesia),
io:format("session_db_type = ~p~n",[Type]),
ok.
