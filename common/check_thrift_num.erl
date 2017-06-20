%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/check_thrift_num.erl
%%
echo(off),


[ begin 
      {StateName, WorkerNum, OverFlowNum, MonitorNum} = poolboy:status(Service),
      if StateName == full ->
              io:format("WARNING !!!!!  ~p WorkerNum ~p  OverFlowNum ~p MonitorNum:~p ~n", [Service, WorkerNum, OverFlowNum, MonitorNum]);
         OverFlowNum > 0 ->
              io:format("WARNING ~p Worker ~p OverFlowNum ~p MonitorNum:~p ~n", [Service, WorkerNum, OverFlowNum, MonitorNum]);
         true ->
              ignore
      end
  end || Service <- [user_service_thrift, conference_service_thrift, rtc_service_thrift, groupService_thrift, behavior_service_thrift, text_parse_service_thrift]],
ok.
