% input:
%
% op: stop idle cliet
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-msync3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/stop_idle_client.erl

echo(off),
        
Pids = [Pid || {_, Pid, _, _} <- supervisor:which_children(msync_client_sup)],
lists:foreach(fun (Pid) ->
                      {state, Socket} = sys:get_state(Pid),
                      case erlang:port_info(Socket) of
                          undefined ->
                              supervisor:terminate_child(msync_client_sup, Pid);
                          _ ->
                              ok
                      end
              end, Pids),
ok.
