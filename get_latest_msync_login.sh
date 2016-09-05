#!/bin/sh
if test $# -ne 1; then
    echo "usage:"
    echo "  $0 org#app"
    exit 1
fi
appkey=$1
dir="/data/apps/opt/msync/log"
servers=`cat  /data/shell/msyncconnlist.txt |sed s/#//g`
for server in $servers
do
    users=`ssh -p3299 ${server} "cd ${dir}; ls -lrt info.log*|tail -5|awk '{print \\\$9}'|xargs grep ${appkey} | grep open_session" | sed "s/@/ /g"|awk '{print $11}'`
    if [[ $users != "" ]]; then
    for user in $users
    do
        ./erl_expect -sname msync@${server} msync/get_version.erl ${user} | grep -v not_found
    done
fi
done
