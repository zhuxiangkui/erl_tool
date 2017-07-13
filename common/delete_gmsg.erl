% input: appkey or appkey file
%
% op: delete gmsg index
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-msync3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/delete_gmsg.erl -afile absolute/path/to/file
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-msync3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/delete_gmsg.erl -appkey easemob-demo#chatdemoui

echo(off),

DoDel =
fun (Type, AppKey, Start, End) ->
        Q = [zrange, <<"im:", AppKey/binary, ":", Type/binary>>, Start, End],
        case easemob_redis:q(appconfig, Q) of
            {error, Reason} ->
                io:format("get group or chatroom for appkey: ~p failed, "
                          "start: ~p, end: ~p, reason: ~p~n",
                          [AppKey, Start, End, {appconfig, Reason}]),
                0;
            {ok, RGs} ->
                Gs = [<<"im:gmsg:", R/binary, "@conference.easemob.com">>
                          || R <- RGs],
                Qs = [[del, G] || G <- Gs],
                case easemob_redis:qp(group_msg, Qs) of
                    {error, Reason} ->
                        io:format("deletion for appkey: ~p failed, start: ~p, "
                                  "end: ~p, reason: ~p~n",
                                  [AppKey, Start, End, {group_msg, Reason}]),
                        0;
                    Rs ->
                        length([R || {ok, <<"1">>} = R <- Rs])
                end
        end
end,

Del =
fun D(Type, AppKey, Start, End, Acc) ->
        case Start > End of
            true ->
                Acc;
            false ->
                L = DoDel(Type, AppKey, Start, Start + 1000),
                D(Type, AppKey, Start + 1001, End, L + Acc)
        end
end,

Delete =
fun (AppKey) ->
        case AppKey of
            <<>> ->
                ok;
            _ ->
                io:format("delete for appkey: ~p~n", [AppKey]),
                Q = [[zcard, <<"im:", AppKey/binary, ":groups">>],
                     [zcard, <<"im:", AppKey/binary, ":chatrooms">>]],
                case easemob_redis:qp(appconfig, Q) of
                    [{ok, BLG}, {ok, BLC}] ->
                        LG = binary_to_integer(BLG),
                        LC = binary_to_integer(BLC),
                        LG2 = Del(<<"groups">>, AppKey, 0, LG, 0),
                        LC2 = Del(<<"chatrooms">>, AppKey, 0, LC, 0),

                        io:format("~p in ~p groups or chatrooms deleted"
                                  " for appkey: ~p~n",
                                  [LG2 + LC2, LG + LC, AppKey]);
                    {error, Reason} ->
                        io:format("deletion for appkey: ~p failed, reason: ~p~n",
                                  [AppKey, {appconfig, Reason}])
                end
        end
end,

DoDelete =
fun (Parent, AppKeys) ->
        AKs = [binary:replace(A, <<"/">>, <<"#">>) || A <- AppKeys],
        lists:foreach(fun (A) ->
                              Delete(A)
                      end, AKs),
        Parent ! done
end,

ParDelete =
fun PD(Parent, AppKeys) ->
        case AppKeys of
            As when length(As) =< 10 ->
                spawn(fun () -> DoDelete(Parent, As) end);
            _ ->
                {Hs, Ts} = lists:split(10, AppKeys),
                spawn(fun () -> DoDelete(Parent, Hs) end),
                PD(Parent, Ts)
        end
end,

Loop =
fun L(N) ->
        case N of
            0 ->
                io:format("deletion finished~n");
            _ ->
                receive
                    done ->
                        L(N - 1)
                end
        end
end,

DeleteFile =
fun (FileName) ->
        {ok, Data} = file:read_file(FileName),
        AppKeys = binary:split(Data, <<"\n">>, [global]),
        ParDelete(self(), AppKeys),
        L = length(AppKeys),
        N = case L rem 10 of
                0 ->
                    L div 10;
                _ ->
                    L div 10 + 1
            end,
        Loop(N)
end,
        
case Args of
    ["-appkey", RawAppKey] ->
        AppKey = list_to_binary(RawAppKey),
        Delete(AppKey);
    ["-afile", AppKeyFileName] ->
        DeleteFile(AppKeyFileName);
    _ ->
        io:format("wrong args~n")
end,
ok.
