echo(on),
restart_module:stop(mod_easemob_sendmsg),
restart_module:start(mod_easemob_sendmsg),
lists:foreach(fun(Pid) ->
                      erlang:unlink(Pid)
              end, element(2,process_info(self(), links))),
ok.
