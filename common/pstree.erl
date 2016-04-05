echo(off),
[App0] = Args,
App = list_to_atom(App0),


ShowProcess =
fun (Level, Pid) ->
        try
            Indent = lists:duplicate(Level * 2, 32),
            Num = erlang:length(element(2,erlang:process_info(Pid, links))),
            case erlang:process_info(Pid, registered_name) of
                {registered_name, Name0} ->
                    io_lib:format("~s~p(~s): ~p~n", [Indent, Pid, Name0, Num]);
                _ ->
                    io_lib:format("~s~p: ~p~n", [Indent, Pid, Num])
            end
        catch
            _C:_E ->
                %% io:format("~p ~p ~p~n",[_C, _E, erlang:get_stacktrace()]),
                []
        end
end,

Walk =
fun Walk0(P, {Level, All, Lines}) ->
        %% io:format("P = ~p, Level = ~p, All = ~p~n", [P, Level, sets:to_list(All)]),
        case Level > 100 of
            true ->
                exit(self(), overflow);
            _ ->
                ok
        end,
        case sets:is_element(P, All) of
            true ->
                {Level, All, Lines};
            false ->
                ThisLine = ShowProcess(Level, P),
                NewLines = [ThisLine | Lines],
                NewAll = sets:add_element(P, All),
                NewLevel = Level + 1,
                %% file:write(group_leader(), NewLines),
                try
                    case process_info(P, links) of
                        {links, Links} ->
                            lists:foldl(
                              fun(Link, {AccLevel, AccAll, AccLines}) ->
                                      case is_pid(Link) of
                                          true -> Walk0(Link, {NewLevel, AccAll, AccLines});
                                          false -> {AccLevel, AccAll, AccLines}
                                      end
                              end, {Level, NewAll, NewLines}, Links);
                        _ ->
                            {NewLevel, NewAll, NewLines}
                        end
                catch
                    _:_ ->
                        {NewLevel, NewAll, NewLines}
                end
        end
end,

RootPid = whereis(App),
{LevelX, _, Outputs} = Walk(RootPid, {0, sets:new(), []}),
file:write(erlang:group_leader(), lists:reverse(Outputs)).
