%% input: none
%%
%% op: start/stop child `easemob_rest_event' under message_store_sup
%% op: delete message by mid/file/stdin
%% e.g. 
%% start: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/message_store.erl start_rest_event
%% stop: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/message_store.erl stop_rest_event
%% delete_message_by_mid: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/message_store.erl delete_message_by_mid 279936566221078528
%% delete_message_by_file: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/message_store.erl delete_message_by_file path/to/mid_file
%% delete_message_by_stdin: cat path/to/mid_file | ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/message_store.erl delete_message_by_stdin


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
        ok;
    ["delete_message_by_mid", MID] ->
        easemob_message_body:delete_message(list_to_binary(MID)),
        ok;
    %% MIDs are arranged line by line('\n') in the input file
    %% Input file must be in absolute path and stay at the target machine,
    %% if this is not the case, `delete_message_by_stdin' is recommended
    ["delete_message_by_file", FileName] ->
        {ok, Bin} = file:read_file(FileName),
        MIDList = binary:split(Bin, <<"\n">>, [global]),
        lists:foreach(fun (MID) ->
                              easemob_message_body:delete_message(MID)
                      end, MIDList),
        ok;
    ["delete_message_by_stdin"] ->
        DeleteLoop =
            fun ReadStdin() ->
                    case io:get_line('') of
                        eof ->
                            ok;
                        {error, _} ->
                            ReadStdin();
                        Line ->
                            case string:tokens(Line, "\n") of
                                [MID | _] ->
                                    easemob_message_body:delete_message(
                                      list_to_binary(MID));
                                _ ->
                                    ReadStdin()
                            end
                    end
            end,
        DeleteLoop(),
        ok
end.
