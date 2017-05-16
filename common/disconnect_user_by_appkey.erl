%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/disconnect_user_by_appkey.erl easemob-demo#chatdemoui
%%
echo(on),
case Args of
    [AppKeyB] ->
        AppKey = iolist_to_binary(AppKeyB),
        user_operation:stop(AppKey),
        io:format("disconnect all the users of appkey:~p ~n", [AppKey]);
    [AppKeyB, PlatformB]->
        AppKey = iolist_to_binary(AppKeyB),
        Platform = iolist_to_binary(PlatformB),
        AllC2S = supervisor:which_children(erlang:whereis('ejabberd_c2s_sup')),
        lists:foreach(fun(C2S) ->
                              {undefined,Pid,worker,[ejabberd_c2s]} = C2S,
                              case ejabberd_c2s:get_session_info(Pid) of
                                  {error, Reason} ->
                                      io:format("Error on session ~p due to ~p ~n", [Pid, Reason]);
                                  {_SID, User, _Server, Resource, _Info} ->
                                      case app_config:get_user_appkey(User) of
                                          AppKey ->
                                              case easemob_resource:get_platform_from_res(Resource) == Platform of
                                                  true ->
                                                      io:format("Platform:~p Resource:~p ~n", [Resource, Platform]),
                                                      Pid ! system_shutdown;
                                                  false ->
                                                      ignore
                                              end;
                                          _ ->
                                              ignore
                                      end
                              end
                      end, AllC2S),
        io:format("disconnect all the users of appkey ~p with Platform:~p ~n", [AppKey, Platform])
end,
ok.
