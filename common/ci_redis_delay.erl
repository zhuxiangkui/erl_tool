% input: none
%
% op: check redis delay
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/ci_redis_delay.erl
%       redis_index_delay_max:0.264
%       redis_index_delay_min:0.207
%       redis_index_delay_avg:0.2355
%       ...

echo(off),
{A, B, C} = os:timestamp(),
random:seed(A, B, C),
GetRedisDelay = 
fun(Table) ->
        lists:foldl(
          fun({N, Pid}, {Max, Min, Avg, Count}) 
                when is_pid(Pid) ->
                  try
                      timer:sleep(1),
		      Key = iolist_to_binary(io_lib:format("~p", [random:uniform()])),
                      case timer:tc(eredis,q,[Pid, [get, Key]]) of
                          {Time0, {ok, _}} ->
			      Time = Time0 / 1000,
			      {max(Max, Time), min(Min, Time), (Avg * Count + Time)/(Count + 1), Count + 1};
                          {Time, Value} ->
			      {50000, Min, 50000, Count + 1}
                      end
                  catch
                      Class:Type ->
			  {50000, Min, 50000, Count + 1}
                  end;
             (_, Acc) ->
		  Acc
          end,{0,50000, 0, 0},
          ets:tab2list(Table))
end,


RedisDelay = 
fun(Table) ->
	{Max, Min, Avg, Count} = GetRedisDelay(Table),
	io:format("redis_~s_delay_max:~p~n",[Table, Max]),
	io:format("redis_~s_delay_min:~p~n",[Table, Min]),
	io:format("redis_~s_delay_avg:~p~n",[Table, Avg]),
	io:format("redis_~s_delay_count:~p~n",[Table, Count])
end,


ModName  =
fun (Mod) ->
	list_to_atom(atom_to_list(Mod) ++ "_easemob.com")
end,

TableExists =
fun(EtsTableName) ->
	case ets:info(EtsTableName) of
	    undefined ->
		false;
	    _ ->
		true
	end
end,

{ok, Tables1} = application:get_env(message_store, redis),
EjabberdTables = lists:filter(
		   TableExists,
		   lists:map(ModName,
			     [ mod_easemob_cache,
			       mod_session_redis,
			       mod_message_log_redis,
			       mod_privacy_cache,
			       mod_message_cache,
			       mod_message_index_cache,
			       mod_muc_room_destroy])),

lists:foreach(RedisDelay, Tables1 ++ EjabberdTables),

ok.

