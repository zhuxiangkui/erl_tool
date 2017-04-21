% input: Modules
%
% op: restart module
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/restart_module.erl Modules

echo(on),
lists:foreach(
   fun(M) ->
      restart_module:restart(list_to_atom(M))
   end, Args),

ok.
