echo(off),

GetDelay =
fun(N) ->
        WorkerName = list_to_atom("odbc_shards_" ++ integer_to_list(N)),
        Worker = cuesport:get_worker(WorkerName),
        SQL = {sql_query, [<<"select 1;">>]},
        try timer:tc(gen_fsm,sync_send_event,[Worker, {sql_cmd, SQL, os:timestamp()}, 5000]) of
            {Time, {selected,[<<"1">>],[[<<"1">>]]}} ->
                Time/1000;
            X ->
                io:format("error ~p~n",[X]),
                60001
        catch
            C:E ->
                io:format("error ~p~n",[{C,E}]),
                60002
        end
end,

Delays = lists:map(GetDelay, lists:seq(0,31)),
lists:foreach(
  fun(Delay) ->
          io:format("odbc delay ~p~n", [Delay])
  end, Delays),

ok.



