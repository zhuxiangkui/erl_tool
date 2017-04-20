% input: App
%
% op: reset application
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/restart_application.erl crypto
%		'ejabberd@ejabberd-worker'  {ok,[crypto]}

echo(off),
[App] = Args,
application:stop(list_to_atom(App)),
Ret = application:ensure_all_started(list_to_atom(App)),
io:format("~p  ~p~n", [node(), Ret]).
