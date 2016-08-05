echo(on),
lists:foreach(
   fun(M) ->
      restart_module:start(list_to_atom(M))
   end, Args),

ok.
