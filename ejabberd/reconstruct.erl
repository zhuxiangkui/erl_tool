% input: none
%
% op: delete all ejabberd c2s sessions and then reconstruct
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/reconstruct.erl

echo(on),
ejabberd_sm:cleanup(),
ejabberd_sm:reconstruct(),
ok.
