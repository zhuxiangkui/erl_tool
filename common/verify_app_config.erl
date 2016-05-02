echo(off),
[BaselineNode0] = Args,
BaselineNode = list_to_atom(BaselineNode0),

lists:foreach(
  fun({app_config, {AppKey, ConfigName}, ConfigValue}) ->
	  case mnesia:dirty_read({app_config, {AppKey, ConfigName}}) of
	      [{app_config, {AppKey, ConfigName}, ConfigValue}] -> ok;
	      MyConfigValue ->
		  io:format("error: baseline ~s.~w = ~w~n, but my config ~s.~w = ~w~n",
			    [AppKey, ConfigName, ConfigValue, 
			     AppKey, ConfigName, MyConfigValue])
	  end
  end, rpc:call(BaselineNode, ets,tab2list, [app_config])),
ok.


