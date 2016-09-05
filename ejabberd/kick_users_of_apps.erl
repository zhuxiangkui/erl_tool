%%%
% 功能：把某些 app 的用户，踢下线
% 参数：<app1> <app2> <app3>
% 用例：./erl_expect -sname ejabberd@ebs-ali-beijing-88 -setcookie secret ejabberd/kick_user_of_apps 'easemob-demo#no1' 'easemob-demo#no2' 'easemob-demo#no3'
% 注意事项：一定要在 session 节点上运行。
%%%
echo(off),
AppKeys = lists:map(fun(X) -> erlang:list_to_binary(X) end, Args),

Kick =
fun({session, {U,S,R},
     {_LoginTime, Pid},
     _US,_Priority,_Info
    }, _Acc) ->
        Appkey = app_config:get_user_appkey(U),
        case lists:member(Appkey, AppKeys) of
            true ->
                io:format("~p ~s~n", [Pid, U]),
                Pid ! system_shutdown,
                ok;
            false ->
                ok
        end
end,

try
    mnesia:activity(
      async_dirty,
      fun() ->
              mnesia:foldl(Kick, ok, session)
      end,mnesia_frag)

catch
    C:E ->
        io:format("error: ~p:~p: ~n",[C,E])
end,
ok.
