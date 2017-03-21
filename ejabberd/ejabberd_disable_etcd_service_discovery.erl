
%%%
% feature: disable etcd service discovery feature on ejabberd
% params :
% example: ./erl_expect -sname ejabberd@ebs-ali-beijing-88 -setcookie secret ejabberd/ejabberd_disable_etcd_service_discovery.erl
%%%

echo(off),
ejabberd_etcd_register:disable_etcd_service_disc(),
ok.
