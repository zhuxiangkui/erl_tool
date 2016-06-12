echo(off),
{ok, List} = application:get_env(migrate_offline, appkey_list),
lists:foreach(
  fun(X) ->
          io:format("~s\n", [X])
  end, List),

ok.
