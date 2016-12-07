%% input: none
%%
%% op: start/stop child `easemob_rest_event' under message_store_sup
%%
%% e.g. 
%% start: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/message_store.erl start_rest_event
%% stop: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/message_store.erl stop_rest_event

echo(off),

Specs = easemob_rest_event:init_spec(),
case Args of
    ["start_rest_event"] ->
        [supervisor:start_child(message_store_sup, Spec) || Spec <- Specs],
        ok;
    ["stop_rest_event"] ->
        Children = [element(1, Spec) || Spec <- Specs],
        lists:foreach(fun (Child) ->
                              supervisor:terminate_child(message_store_sup, Child),
                              supervisor:delete_child(message_store_sup, Child)
                      end, Children),
        ok
end.
