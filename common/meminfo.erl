%% Top memory process
application:start(os_mon),
memsup:set_procmem_high_watermark(0.01),

io:format("{memory_data, ~p, ~p}.~n", [os:timestamp(), memsup:get_memory_data()]),
io:format("{system_memory_data, ~p, ~p}.~n", [os:timestamp(), memsup:get_system_memory_data()]),

%% Allocator info
io:format("{alloc_info_config, ~p, ~p}.~n",[os:timestamp(),  erlang:system_info(allocator)]),
io:format("{alloc_info_mseg_alloc, ~p, ~p}.~n",[os:timestamp(),  erlang:system_info({allocator, mseg_alloc})]),
io:format("{alloc_info_sys_alloc, ~p, ~p}.~n",[os:timestamp(),  erlang:system_info({allocator, sys_alloc})]),
io:format("{alloc_info_eheap_alloc, ~p, ~p}.~n",[os:timestamp(),  erlang:system_info({allocator, eheap_alloc})]),
io:format("{alloc_info_binary_alloc, ~p, ~p}.~n",[os:timestamp(),  erlang:system_info({allocator, binary_alloc})]),

ok.
