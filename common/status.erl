
% input: none
%
% op: ejabberd / msync version
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/status.erl

echo(off),
io:format("MSYNC ~p~n", [application:get_key(msync,vsn)]),
io:format("EJABBERD ~p~n", [application:get_key(ejabberd,vsn)]),
io:format("SRC_SHA1 ~p~n", [fingerprint:src_sha1()]),
io:format("GIT_SHA1 ~p~n", [fingerprint:git_sha1()]),
ok.
