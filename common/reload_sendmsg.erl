ejabberd_config:load_file("/data/apps/opt/ejabberd/etc/ejabberd/ejabberd.yml"),
shaper:load_from_config(),
restart_module:restart(mod_easemob_sendmsg).
