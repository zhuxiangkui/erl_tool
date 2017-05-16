#!/bin/bash
# comment this is script for run erl_tool on docker container
# base on which erl_tool must be on the container
export PATH=$PATH:/data/apps/opt/${1}/erts-7.3/bin/
IP=`echo ${POD_IP}| sed "s/\./-/g"`
HOST="${IP}.${KUB_NAMESPACE}.pod.cluster.local"
Node=${1}@${HOST}
/data/apps/opt/erl_tool/erl_expect -name ${Node} -setcookie ejabberd /data/\
apps/opt/erl_tool/$2
