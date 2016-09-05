for i in `cat  /home/easemob/zhangchao/console_list.txt |grep -v \#`; do
    echo $i;
    ssh -leasemob -p3299 ${i} /data/github_ci/erl_tool/all_msync.sh /data/github_ci/erl_tool/msync/get_num_of_conn.erl
    ssh -leasemob -p3299 ${i} /data/github_ci/erl_tool/all_msync.sh /data/github_ci/erl_tool/msync/get_num_of_workers.erl
done

wait
