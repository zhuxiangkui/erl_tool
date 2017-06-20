%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/check_thrift_num.erl
%%
echo(off),

Result =
[ begin 
      {StateName, WorkerNum, OverFlowNum, MonitorNum} = poolboy:status(Service),
      if StateName == full ->
              io:format("WARNING !!!!!  ~p StateName: ~p WorkerNum ~p  OverFlowNum ~p MonitorNum:~p ~n", [Service, StateName, WorkerNum, OverFlowNum, MonitorNum]),
              2;
         OverFlowNum > 0 ->
              io:format("WARNING ~p StateName :~p Worker ~p OverFlowNum ~p MonitorNum:~p ~n", [Service, StateName, WorkerNum, OverFlowNum, MonitorNum]),
              1;
         true ->
              0
      end
  end || Service <- [user_service_thrift, conference_service_thrift, rtc_service_thrift, groupService_thrift, behavior_service_thrift, text_parse_service_thrift]],
R = lists:foldl(fun(Acc, Ret) -> erlang:max(Acc, Ret) end, 0, Result),
case R > 0 of
    true ->
        exit(R);
    false ->
        ignore
end.
