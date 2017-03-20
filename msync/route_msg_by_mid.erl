
% input: none
%
% op: read MIDs from file, route the muc msg
%
% e.g.: cat file | ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' msync/route_msg_by_mid.erl

echo(off),

Do =
    fun(MID) ->
        %io:format("MID: ~p~n", [MID]),
        case easemob_message_body:read_message(MID) of
            not_found ->
                io:format("not found: mid=~p~n", [MID]),
                ignore;
            Body ->
                Meta = msync_msg:decode_meta(Body),
                %io:format("MID: ~p, Body: ~p~n", [MID, Body]),
                FromJID = msync_msg:get_meta_from(Meta),
                ToJID = msync_msg:get_meta_to(Meta),
                Res = process_muc_queue:route(FromJID, FromJID, ToJID, Meta),
                io:format("route result:~p, mid=~p~n", [Res, MID])
        end
    end,

Loop =
    fun ReadStdIO() ->
        case io:get_line('') of
            eof ->
                ignore;
            {error, _} ->
                ReadStdIO();
            MID ->  % MID: 255922209669775984
                Do(list_to_binary(string:strip(MID, both, $\n))),
                ReadStdIO()
        end
    end,

Loop().
