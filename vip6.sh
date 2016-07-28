# sh vip6.sh ejabberd@vip6-ali-beijing-ejabberd101 common/get_sendmsg_status.erl
echo $1
./erl_expect -sname $* -setcookie 'EASEMOBAAAAAAAAAAEBS'
