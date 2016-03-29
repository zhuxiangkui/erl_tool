F = fun(Socket) 
	  when is_port(Socket) ->
	    Opts = inet:getopts(Socket, [active,
					 buffer,
					 delay_send,
					 dontroute,
					 exit_on_close,
					 high_msgq_watermark,
					 high_watermark,
					 ipv6_v6only, 
					 keepalive,
					 linger,
					 low_msgq_watermark,
					 low_watermark,
					 nodelay,
					 packet,
					 packet_size,
					 priority,
					 recbuf,
					 reuseaddr,
					 send_timeout,
					 send_timeout_close,
					 show_econnreset,
					 sndbuf,
					 priority,
					 tos]),
	    io:format("Options are ~p~n", [Opts]);
       (_) ->
	    false
    end,
lists:foreach(F, element(2, process_info(whereis(msync_server), links))).






