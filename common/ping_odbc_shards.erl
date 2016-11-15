echo(off),
WorkerList =
fun(WorkName) ->
        case catch ets:tab2list(WorkName) of
            {'EXIT', _} ->
                io:format("error odbc conn not exist ~s ~n", [node()]),
                [];
            List ->
                List
        end
end,
GetDelayInfo =
fun(N) ->
        WorkerName = list_to_atom("odbc_shards_" ++ integer_to_list(N)),
        SQL = {sql_query, [<<"select 1;">>]},
        lists:filtermap(
          fun({N2, Worker})
                when is_pid(Worker)->
                  case catch sys:get_state(Worker) of
                      {'EXIT', _} ->
                          io:format("restart delayed odbc conn ~s ~p ~p ~p ~n", [node(), N , N2,  Worker ]),
                          exit(Worker, kill),
                          false;
                      State ->
                          %% # {state,<7121.9910.3894>,mysql,
                          %% #                             [<<"rds4077hl6n7cv79795i.mysql.rds.aliyuncs.com">>,
                          %% #                              3306,<<"ejabberd">>,<<"ejabberd">>,
                          %% #                              <<"ejabberd">>],
                          %% #                             30000000,1000,
                          %% #                             {0,{[],[]}}}1
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
                          {true, {N, N2, Delay, Worker, State}}
                  end;
             ({pool_size, _}) ->
                  false;
             ({seq, _}) ->
                  false;
             (Error) ->
                  io:format("error odbc conn not exist ~s ~p ~n", [node(), Error]),
                  false
          end, WorkerList(WorkerName))
end,
DelayInfos = lists:flatmap(GetDelayInfo, lists:seq(0,31)),
LargeDelays = lists:filter(
                fun({N, N2, Delay, Pid, {_, State}}) when Delay > 1000 ->
                        io:format("restart delayed odbc conn ~s ~p ~p ~p ~s ~p ~p~n", [node(), N , N2, Delay, lists:nth(1,element(4,State)), lists:nth(2,element(4,State)), Pid ]),
                        exit(Pid, kill),
                        true;
                   (_) ->
                        false
                end, DelayInfos),
timer:sleep(2000),
DelayInfos2 = lists:flatmap(GetDelayInfo, lists:seq(0,31)),
lists:foreach(
  fun({N, N2, Delay, Pid, {_, State}}) ->
          io:format("odbc conn ~s ~p ~p ~p ~s ~p ~p~n", [node(), N , N2, Delay, lists:nth(1,element(4,State)), lists:nth(2,element(4,State)) , Pid]),
          true;
     (_) ->
          false
  end, DelayInfos2),
ok.
