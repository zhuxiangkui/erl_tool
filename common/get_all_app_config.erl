echo(off),

lists:foreach(
  fun({app_config, {AppKey, ConfigName}, ConfigValue}) ->
          io:format("~p ~s ~p ~p~n", [ node(), AppKey, ConfigName, ConfigValue])
  end,
  ets:tab2list(app_config)),



ok.
