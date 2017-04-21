% input: Modules
%
% op: start module
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/start_module.erl Modules

echo(on),
lists:foreach(
   fun(M) ->
      restart_module:start(list_to_atom(M))
   end, Args),

ok.
