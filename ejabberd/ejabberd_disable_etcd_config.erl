% input: none
%
% op: disable etcd configure management feature on ejabberd
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-88 -setcookie secret ejabberd/ejabberd_disable_etcd_config.erl

echo(off),
ok = ejabberd_etcd_config:disable_etcd_config(),
ok.
