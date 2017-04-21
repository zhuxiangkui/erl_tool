% input: Modules
%
% op: stop module
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/stop_module.erl Modules

echo(on),
lists:foreach(
   fun(M) ->
      restart_module:stop(list_to_atom(M))
   end, Args),

ok.
