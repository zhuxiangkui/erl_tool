echo(on),
lists:foreach(
   fun(M) ->
      restart_module:stop(list_to_atom(M))
   end, Args),

ok.
