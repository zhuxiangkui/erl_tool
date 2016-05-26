%% Top memory process
application:start(os_mon),
memsup:set_procmem_high_watermark(0.01),

MemData = memsup:get_memory_data(),
io:format("{memory_data, ~p, ~p}.~n", [os:timestamp(), MemData]),

case MemData of
    {_,_, undefined} ->
        ok;
    {_,_, {WorstPid, WorstMem}} ->
        io:format("{memory_data_worst, ~p, ~p}.~n",[os:timestamp(),
                                              {WorstPid, WorstMem, process_info(WorstPid, [registered_name, initial_call, message_queue_len, current_stacktrace])}])
end,

io:format("{system_memory_data, ~p, ~p}.~n", [os:timestamp(), memsup:get_system_memory_data()]),

%% Allocator info
io:format("{alloc_info_config, ~p, ~p}.~n",[os:timestamp(),  erlang:system_info(allocator)]),
io:format("{alloc_info_mseg_alloc, ~p, ~p}.~n",[os:timestamp(),  erlang:system_info({allocator, mseg_alloc})]),
io:format("{alloc_info_sys_alloc, ~p, ~p}.~n",[os:timestamp(),  erlang:system_info({allocator, sys_alloc})]),
io:format("{alloc_info_eheap_alloc, ~p, ~p}.~n",[os:timestamp(),  erlang:system_info({allocator, eheap_alloc})]),
io:format("{alloc_info_binary_alloc, ~p, ~p}.~n",[os:timestamp(),  erlang:system_info({allocator, binary_alloc})]),

ok.
