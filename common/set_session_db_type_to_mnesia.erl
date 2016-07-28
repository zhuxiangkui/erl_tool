
% input: none
%
% op: set mnesia session
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/set_session_db_type_to_mnesia.erl

echo(off),
ejabberd_sm:set_session_db_type(mnesia),
ok.
