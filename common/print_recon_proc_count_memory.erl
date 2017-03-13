echo(off),
io:format("========================================~n"),
io:format("time : ~p~n", [erlang:localtime()]),
io:format("---> memory proc count info~n"),
[begin
    io:format("~p~n", [[Proc, {'memory(M)', Memory/1024/1024}, recon:info(Proc, registered_name),
                        recon:info(Proc, current_location), recon:info(Proc, current_function)]])
 end || {Proc, Memory, _} <- recon:proc_count(memory, 5)],
io:format("---> reductions proc window info~n"),
[begin
    io:format("~p~n", [[Proc, {'reductionwindow', ReductionsWindow}, recon:info(Proc, registered_name),
                        recon:info(Proc, current_location), recon:info(Proc, current_function)]])
 end || {Proc, ReductionsWindow, _} <- recon:proc_window(reductions, 5, 500)],
io:format("---> message_queue_len proc count info~n"),
[begin
    io:format("~p~n", [[Proc, {'message_queue_len', MsgQueueLen}, recon:info(Proc, registered_name),
                        recon:info(Proc, current_location), recon:info(Proc, current_function)]])
 end || {Proc, MsgQueueLen, _} <- recon:proc_count(message_queue_len, 5)],
io:format("---> binary leak info~n"),
[begin
    io:format("~p~n", [[Proc, {'bin_leak', BinLeak}, recon:info(Proc, registered_name),
                        recon:info(Proc, current_location), recon:info(Proc, current_function)]])
 end || {Proc, BinLeak, _} <- recon:bin_leak(5)],
io:format("---> total erlang process num~n"),
io:format("~p~n", [erlang:length(erlang:processes())]),
ok.
