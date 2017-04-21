% input: none
%
% op: restart thrift for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/restart_thrift_service.erl

echo(off),
ejabberd_app:stop_thrift_service(),
ejabberd_app:start_thrift_service(),
io:format("user service thrift: ~p ~n", [whereis('user_service_thrift')]),
io:format("group service thrift: ~p ~n", [whereis('groupService_thrift')]),
ok.
