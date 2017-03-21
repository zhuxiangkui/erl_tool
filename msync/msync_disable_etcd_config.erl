
%%%
% feature: disable etcd configure management feature on msync
% params :
% example: ./erl_expect -sname msync@ebs-ali-beijing-88 -setcookie secret msync/msync_disable_etcd_config.erl
%%%

echo(off),
ok = msync_etcd_config:disable_etcd_config(),
ok.
