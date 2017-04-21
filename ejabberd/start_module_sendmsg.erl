% input: none
%
% op: start mod_easemob_sendmsg for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/start_module_sendmsg.erl

echo(on),
restart_module:start(mod_easemob_sendmsg),
lists:foreach(fun(Pid) ->
                       erlang:unlink(Pid)
              end, element(2,process_info(self(), links))),
ok.

