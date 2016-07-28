
% input: none
%
% op: set codis session
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/set_session_db_type_to_codis.erl

echo(off),
ejabberd_sm:set_session_db_type(redis),
ok.
