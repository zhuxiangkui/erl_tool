% input: none
%
% op: read one MID from file, read body from codis, then write to mysql
%
% e.g.: cat file | ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/repair_body_odbc_io.erl

echo(off),

Do =
    fun(MID) ->
        %io:format("MID: ~p~n", [MID]),
        case easemob_message_body:read_message(MID) of
            not_found ->
                %io:format("not found: ~p~n", [MID]),
                ignore;
            Body ->
                %io:format("MID: ~p, Body: ~p~n", [MID, Body]),
                easemob_message_body:write_message_ssdb(MID, Body)
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
