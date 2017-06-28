%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/health_check.erl
%%
echo(on),
Result = health_check:check(),
maps:fold(fun(K, V, Acc) ->
                  #{status := Status} = V,
                  case Status of
                      normal->
                          ok;
                      warn ->
                          ok;
                      false ->
                          io:format("Result:~p ~n", [Result]),
                          exit(1)
                  end
          end, ok, Result).
