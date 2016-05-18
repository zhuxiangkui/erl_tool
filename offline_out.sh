## example: sh offline_out.sh user.txt body.txt redis 6379 result.txt test
## 说明如下：（一下文件均指单行）
## user.txt 数据输入源 easemob-demo#chatdemoui_mt001@easemob.com 197457060269391872
## body.txt 需要迁移的消息体，供消息体迁移使用 格式如197480673328497452
## redis 离线消息迁移的redis queue
## port 6379 : the port of redis queue
## result.txt 执行完成lpush之后的结果
## test 消息队列中的topic
echo "========     output indice        ======"
echo "****** output the indice of user's offline ******"
cat -n $1 | sort -k2,2 -k1,1n | uniq -f1 | sort -k1,1n | cut -f2- | sed 's/\(.*\)@easemob.com \(.*\)/{<<\"\1\">>,<<\"\2\">>}./g' > expect_insert.txt
touch $PWD/without_ack.txt
./erl_expect -sname ejabberd@zhangchao common/check_user_offlinemsg.erl $PWD/expect_insert.txt $PWD/without_ack.txt
cat without_ack.txt | sed 's/[<">]//g' > offline.txt
echo "======== output offline indice End======"

echo "=========     output body         ======="
echo "*****output the indice of message body which need to be transfer back****"
cat offline.txt | sort -k2,2 -k1,1n | uniq -f1 | sort -k1,1n | cut -f2- | sed 's/.* \(.*\)/\1/g' > $2
echo "=========    output body end      ======="

echo "=========     make redis query          ======="
cat $2 | sed "s/\(.*\)/lpush $6 \1/g" | redis-cli -h $3 -p $4  > $5
echo "=========    make redis query  end      ======="
