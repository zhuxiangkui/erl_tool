echo(on),
lists:foreach(
   fun(M) ->
      restart_module:restart(list_to_atom(M))
   end, Args),

ok.
