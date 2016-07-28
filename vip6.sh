# sh vip6.sh vip6-ali-beijing-ejabberd101 common/get_sendmsg_status.erl
echo $1
./erl_expect -sname ejabberd@$1 -setcookie 'EASEMOBAAAAAAAAAAEBS' $2
