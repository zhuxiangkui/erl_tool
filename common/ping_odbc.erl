%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/pign_odbc.erl
%%
echo(off),

SQL = {sql_query, [<<"select 1;">>]},

GetDelayInfo =
fun({N2, Worker})
      when is_pid(Worker)->
        case catch sys:get_state(Worker) of
            {'EXIT', _} ->
                io:format("restart delayed odbc conn ~s ~p ~p ~n", [node(), N2,  Worker ]),
                exit(Worker, kill),
                false;
            State ->
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
                {true, {N2, Delay, Worker, State}}
        end;
   ({pool_size, _}) ->
        false;
   ({seq, _}) ->
        false;
   (_) ->
        io:format("error odbc conn not exist ~s ~n", [node()]),
        false
end,
WorkerList =
fun() ->
        case catch ets:tab2list(odbc) of
            {'EXIT', _} ->
                io:format("error odbc conn not exist ~s ~n", [node()]),
                [];
            List ->
                List
        end
end,

DelayInfos = lists:filtermap(GetDelayInfo, WorkerList()),

LargeDelays = lists:filter(
                fun({N2, Delay, Pid, {_, State}}) when Delay > 1000 ->
                        io:format("restart delayed odbc conn ~s ~p ~p ~s ~p ~p~n", [node(), N2, Delay, lists:nth(1,element(4,State)), lists:nth(2,element(4,State)), Pid ]),
                        exit(Pid, kill),
                        true;
                   (_) ->
                        false
                end, DelayInfos),
timer:sleep(2000),
DelayInfos2 = lists:filtermap(GetDelayInfo, WorkerList()),
lists:foreach(
  fun({N2, Delay, Pid, {_, State}}) ->
          io:format("odbc conn ~s ~p ~p ~s ~p ~p~n", [node(), N2, Delay, lists:nth(1,element(4,State)), lists:nth(2,element(4,State)) , Pid]),
          true;
     (_) ->
          false
  end, DelayInfos2),
ok.
