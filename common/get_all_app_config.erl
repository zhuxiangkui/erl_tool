% input: none
%
% op: look up all app_config in the node
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-59-pri common/get_all_app_config.erl
%       'ejabberd@ebs-ali-beijing-59-pri' jinhe2015#jinhe separate_worker sub
%		'ejabberd@ebs-ali-beijing-59-pri' szzm#peiliao muc_presence_async true
%       ...

echo(off),

lists:foreach(
  fun({app_config, {AppKey, ConfigName}, ConfigValue}) ->
          io:format("~p ~s ~p ~p~n", [ node(), AppKey, ConfigName, ConfigValue]);
     (What) ->
          io:format("What = ~p~n", [ What ])
  end,
  ets:tab2list(app_config)),



ok.
