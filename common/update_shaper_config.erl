% input: none	
%
% op: update shaper config
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-59-pri common/update_shaper_config.erl
% 
echo(off),
shaper:load_from_config(),
io:format("~p  ~p~n", [node(), ets:tab2list(shaper)]).
