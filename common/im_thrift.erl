%% input: none
%%
%% op: start/stop im_thrift application
%%
%% e.g. 
%% start: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/im_thrift.erl start
%% stop: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/im_thrift.erl stop

echo(off),

case Args of
    ["start"] ->
        application:start(im_thrift),
        ok;
    ["stop"] ->
        application:stop(im_thrift),
        ok
end.
