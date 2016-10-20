%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/delete_users_msg.erl
%%
echo(on),
[Appkey, UserFile] = Args,
{ok, [Users]} = file:consult(UserFile),
AppB = erlang:list_to_binary(Appkey),
lists:foldl(fun(User, Count) ->
                    UserB = erlang:list_to_binary(erlang:atom_to_list(User)),
                    UserDomain = <<AppB/binary, "_", UserB/binary, "@easemob.com">>,
                    message_store:delete_user(UserDomain, <<"">>, 0),
                    NewCount = Count + 1,
                    case NewCount rem 100 of
                        0 ->
                            io:format("the current process is NewCount:~p ~n", [NewCount]);
                        _ ->
                            ignore
                    end,
                    NewCount
              end, 0, Users),
ok.
