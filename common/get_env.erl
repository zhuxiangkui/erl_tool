% input: AppKey ConfigName
%
% op: look up app_config
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd' common/get_env.erl easemob-demo#chatdemoui message_store
%       'ejabberd@ejabberd-worker'  undefined

echo(off),
[App, Name] = Args,
io:format("~p  ~p~n", [node(), application:get_env(list_to_atom(App), erlang:list_to_atom(Name))]).
