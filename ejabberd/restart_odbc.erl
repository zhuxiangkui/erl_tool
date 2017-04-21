% input: none
%
% op: restart odbc
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/restart_odbc.erl

echo(off),
F1 =
fun( P ) ->
        {_,V} = process_info(P, dictionary),
        {state,PP,_,_,_,_,_,_,_} = proplists:get_value(ejabberd_odbc_state, V),
        PP
end,
PL = [F1( P) || P <- ejabberd_odbc_sup:get_pids(<<"easemob.com">>)],

F2 =
fun( P) ->
        case  erlang:process_info(P, current_function) of
            {current_function,{p1_mysql_conn,_,_}} ->
                true;
            _ ->
                false
        end
end,

PL2 = [ P || P <-erlang:processes(), F2( P) ],

[ P ! stop || P <- PL2 -- PL].
