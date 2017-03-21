
%%%
% feature: disable etcd service discovery feature on msync
% params :
% example: ./erl_expect -sname msync@ebs-ali-beijing-88 -setcookie secret msync/msync_disable_etcd_service_discovery.erl
%%%

echo(off),
msync_etcd_register:disable_etcd_service_disc(),
ok.
