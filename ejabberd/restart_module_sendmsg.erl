% input: none
%
% op: restart mod_easemob_sendmsg for ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/restart_module_sendmsg.erl

echo(on),
restart_module:stop(mod_easemob_sendmsg),
restart_module:start(mod_easemob_sendmsg),
lists:foreach(fun(Pid) ->
                      erlang:unlink(Pid)
              end, element(2,process_info(self(), links))),
ok.
