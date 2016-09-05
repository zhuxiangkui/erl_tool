for i in `cat  /data/shell/ejabberworkerlist.txt |sed s/#//g`; do
    echo '==================='    $i; 
    ./erl_expect -sname ejabberd@${i}-pri -setcookie EASEMOBAAAAAAAAAAEBS $* 
done

wait
