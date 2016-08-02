echo(off),
ejabberd_config:load_file("/data/apps/opt/ejabberd/etc/ejabberd/ejabberd.yml"),
io:format("load config finished ~n",[]).
