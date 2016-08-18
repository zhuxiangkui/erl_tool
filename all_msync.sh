for i in `cat  /data/shell/msyncconnlist.txt |sed s/#//g`; do
    echo '                         '    $i;
    /data/github_ci/erl_tool/erl_expect -sname msync@${i} -setcookie EASEMOBAAAAAAAAAAEBS $* &
done

wait
