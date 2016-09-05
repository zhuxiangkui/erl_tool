
% input: none
%
% op: ejabberd / msync version
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/status.erl

echo(off),
%io:format("MSYNC: ~p~n", [application:get_key(msync,vsn)]),
%io:format("EJABBERD ~p~n", [application:get_key(ejabberd,vsn)]),
%io:format("SRC_SHA1 ~p~n", [fingerprint:src_sha1()]),
%io:format("GIT_SHA1 ~p~n", [fingerprint:git_sha1()]),
io:format("MSYNC: ~p, EJABBERD: ~p, SRC_SHA1: ~p, GIT_SHA1: ~p~n",
          [application:get_key(msync,vsn), application:get_key(ejabberd,vsn), fingerprint:src_sha1(), fingerprint:git_sha1()]),
ok.
