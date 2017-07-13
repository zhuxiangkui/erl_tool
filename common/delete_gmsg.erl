% input: appkey or appkey file
%
% op: delete gmsg index
%
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-msync3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/delete_gmsg.erl -afile absolute/path/to/file
% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-msync3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/delete_gmsg.erl -appkey easemob-demo#chatdemoui

echo(off),

Delete =
fun (AppKey) ->
        case AppKey of
            <<>> ->
                ok;
            _ ->
                io:format("delete for appkey: ~p~n", [AppKey]),
                Q = [[zrange, <<"im:", AppKey/binary, ":groups">>, 0, -1],
                     [zrange, <<"im:", AppKey/binary, ":chatrooms">>, 0, -1]],
                case easemob_redis:qp(appconfig, Q) of
                    [{ok, Groups}, {ok, Chatrooms}] ->
                        Gs = [<<"im:gmsg:", G/binary, "@conference.easemob.com">>
                                  || G <- Groups ++ Chatrooms],
                        Qs = [[del, G] || G <- Gs],
                        case easemob_redis:qp(index, Qs) of
                            {error, Reason} ->
                                io:format("deletion for appkey: ~p failed, reason: ~p~n",
                                          [AppKey, {index, Reason}]);
                            Rs ->
                                LG = length(Groups),
                                LC = length(Chatrooms),
                                L = length([R || {ok, <<"1">>} = R <- Rs]),
                                io:format("~p in ~p groups or chatrooms deleted"
                                          " for appkey: ~p~n",
                                          [L, LG + LC, AppKey])
                        end;
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
