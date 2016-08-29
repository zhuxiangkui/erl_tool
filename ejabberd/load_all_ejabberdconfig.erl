echo(off),
ejabberd_config:load_file("/data/apps/opt/ejabberd/etc/ejabberd/ejabberd.yml"),
config:load_env("/data/apps/opt/ejabberd/etc/ejabberd/message_store.config"),
io:format("load config finished ~n",[]).
