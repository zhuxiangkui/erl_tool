echo(off),
NumOfWorkers = msync_c2s_guard:get_num_of_workers(),

{ok, Overload} = application:get_env(msync, overload),

case NumOfWorkers > Overload of
    true ->
	%% when system is overload, enable bypass mode
	io:format("error: enable bypass mode! W = ~p~n", [NumOfWorkers]),
	msync_user:auth_opt(bypassed, true);
    false ->
	%% otherwise, back to normal
	io:format("info: everything looks ok! W = ~p~n", [NumOfWorkers]),
	msync_user:auth_opt(bypassed, false)
end,


ok.

