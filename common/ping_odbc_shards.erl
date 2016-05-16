echo(off),

GetDelayInfo =
fun(N) ->
        WorkerName = list_to_atom("odbc_shards_" ++ integer_to_list(N)),
        Worker = cuesport:get_worker(WorkerName),
        SQL = {sql_query, [<<"select 1;">>]},
	State = sys:get_state(Worker),
%% # {state,<7121.9910.3894>,mysql,
%% #                             [<<"rds4077hl6n7cv79795i.mysql.rds.aliyuncs.com">>,
%% #                              3306,<<"ejabberd">>,<<"ejabberd">>,
%% #                              <<"ejabberd">>],
%% #                             30000000,1000,
%% #                             {0,{[],[]}}}
        Delay = try timer:tc(gen_fsm,sync_send_event,[Worker, {sql_cmd, SQL, os:timestamp()}, 5000]) of
            {Time, {selected,[<<"1">>],[[<<"1">>]]}} ->
                Time/1000;
            X ->
                %% io:format("error ~w~n",[X]),
                60001
        catch
            C:E ->
                %% io:format("error ~w~n",[{C,E}]),
                60002
        end,
	{N, Delay, State}
end,

DelayInfos = lists:map(GetDelayInfo, lists:seq(0,31)),
lists:foreach(
  fun({N, Delay, {_, State}}) ->
          io:format("odbc delay ~s ~p ~p ~s ~p~n", [node(), N, Delay, lists:nth(1,element(4,State)), lists:nth(2,element(4,State)) ])
  end, DelayInfos),

ok.



