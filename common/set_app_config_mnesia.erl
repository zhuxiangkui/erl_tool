% input: none
%
% op: syn appconfig from redis to mnesia
%
% e.g.:  ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/set_app_config_mnesia.erl

echo(off),
io:format("syn appconfig from redis to mnesia => ~p~n",[app_config:load_app_config()]),
ok.


