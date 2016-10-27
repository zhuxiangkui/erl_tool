%% input: none
%%
%% op: start/stop/get_state/set  lager_event_watcher (inside lager_sup)
%%
%% e.g. 
%% start: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/lager_event_watcher.erl start
%% stop ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/lager_event_watcher.erl stop
%% get_state ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/lager_event_watcher.erl get_state
%% set ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/lager_event_watcher.erl threshold|interval|max_over_cnt|reboot_after N
%% e.g.
%% ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/lager_event_watcher.erl threshold 1000

echo(off),

case Args of
    ["start"] ->
        Threshold = application:get_env(lager, event_watcher_threshold, 1000),
        Interval = application:get_env(lager, event_watcher_interval, 1000),
        MaxOverCnt = application:get_env(lager, event_watcher_max_over_cnt, 3),
        RebootAfter = application:get_env(lager, event_watcher_reboot_after, 5000),

        Watcher = {lager_event_watcher, {lager_event_watcher, start_link, 
                                         [Threshold, Interval, MaxOverCnt, RebootAfter]},
                   permanent, 5000, worker, [lager_event_watcher]},
        
        supervisor:terminate_child(lager_sup, lager_event_watcher),
        supervisor:delete_child(lager_sup, lager_event_watcher),
        supervisor:start_child(lager_sup, Watcher),
        application:set_env(lager_sup, event_watcher, true),
        ok;
    ["stop"] ->
        supervisor:terminate_child(lager_sup, lager_event_watcher),
        supervisor:delete_child(lager_sup, lager_event_watcher),
        application:set_env(lager_sup, event_watcher, false),
        ok;
    ["get_state"] ->
        lager_event_watcher:get_state();
    [Key, Value] when Key == "threshold";
                      Key == "interval";
                      Key == "max_over_cnt";
                      Key == "reboot_after" ->
        try list_to_integer(Value) of
            N ->
                lager_event_watcher:set(list_to_atom(Key), N)
        catch
            _C:_R ->
                ignore
        end;
    _ ->
        ignore
end.
        
