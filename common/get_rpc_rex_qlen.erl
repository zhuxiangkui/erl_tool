echo(off),
{message_queue_len, QLen} = process_info(whereis(rex), message_queue_len),
io:format("rex_queue_len:~p~n", [QLen]),
ok.
