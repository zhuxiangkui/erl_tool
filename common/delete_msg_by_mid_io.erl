% input: RunMode
%
% op: delete msg according to given mid
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/delete_msg_by_mid_io.erl RunMode

echo(off),

%% RunMode: delete | dry_run

RunMode = Args,

DoDelete =
    fun(Mid) ->
        io:format("Mid: ~p~n", [Mid]),
        RedisWorker = cuesport:get_worker(body),
        SSDBWorker = cuesport:get_worker(ssdb_body),    
        eredis:q(RedisWorker, [del, <<"im:message:", Mid/binary>>]),
        eredis:q(SSDBWorker, [del, <<"im:message:", Mid/binary>>])
    end,

LoopDelete =
    fun ReadStdIO() ->
        case io:get_line('') of
            eof ->
                ignore;
            {error, _} ->
                ReadStdIO();
            Mid0 ->
                io:format("Mid0: ~p~n", [Mid0]),
                DoDelete(list_to_binary(string:strip(Mid0, both, $\n))),
                ReadStdIO()
        end
    end,

LoopDelete().


