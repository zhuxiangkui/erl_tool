% input: none
%
% op: restart mod_easemob_sendmsg
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-59-pri common/reload_sendmsg.erl

shaper:load_from_config(),
restart_module:restart(mod_easemob_sendmsg).
