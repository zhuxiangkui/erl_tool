
## `check_conn_num.erl`

参数： 无
用途： 得到已经登录的用户个数，比 socket 的个数略少
例子：

## `check_store_nodes.erl`

参数: 无
用途：检查 all, sub, muc 节点的可用性，删除不可用的节点。
例子：


## `close_all_connection.erl`

参数：无
用途：删除所有连接，俗称踢人
注意事项：慎用
例子：


## `enable_socket_option.erl`
保留命令，一般不用

## `get_server_opt.erl`
保留命令，一般不用

## `health.erl`
参数：无
用途：得到 msync 的健康状态
例子：

```
./erl_expect -echo -sname msync@ebs-ali-beijing-msync1 -setcookie XXXXX msync/health.erl

# 当前运行的进程数，均值和配置相关。刚刚启动时，没有任何连接的条件下，是底值。在此之上，增加的进程数表示系统负载。一般来说，进程数不应该超过1800 个。
process_count:1349
# 系统配置，进程数的限制
process_limit:4194304
# 端口数目，包含打开 socket 的个数和打开文件的个数。
port_count:16352
# 系统配置，端口数目限制
port_limit:1048576
# 系统内存总量，包含虚拟内存，虚拟内存很大不影响系统稳定性
mem_total:4051490848
# 进程所占总内存
mem_processes:178784496
# 进程的堆所占的总内存
mem_processes_used:178666800
# 系统内存
mem_system:3872706352
# atom 数目
mem_atom:1984737
# atom 所占的内存
mem_atom_used:1970040
# binary 所占的内存，这个大多数是虚拟内存，大一点没关系。
mem_binary:3667754280
# 代码内存
mem_code:61231688
# ets 表内存
mem_ets:13958208
# 当前有效的用户数
num_of_connected_users:15282
# 当前打开 IM 的  socket 连接数，还没有认证的。
num_of_sockets:15378
# 当前工作进程数目，不应该超过 10 ，超过则报警
num_of_workers:2
# 下面是  codis 的延时，分为 max, min, avg, count
# count 表示采样点的个数
# avg 平均延时，单位是毫秒
# max 最大延时，min 最小延时
# max 是最有用的报警指标 ，超过 50 ms 就应该报警
# 这样报警也许过于频繁， 我们在根据经验调整
redis_index_delay_max:14.335
redis_index_delay_min:2.105
redis_index_delay_avg:2.8031200000000003
redis_index_delay_count:100
redis_body_delay_max:6.897
redis_body_delay_min:2.136
redis_body_delay_avg:2.5531100000000007
redis_body_delay_count:100
redis_appconfig_delay_max:0.343
redis_appconfig_delay_min:0.343
redis_appconfig_delay_avg:0.343
redis_appconfig_delay_count:1
redis_roster_delay_max:0.298
redis_roster_delay_min:0.298
redis_roster_delay_avg:0.298
redis_roster_delay_count:1
redis_log_delay_max:5.16
redis_log_delay_min:0.276
redis_log_delay_avg:0.8563000000000001
redis_log_delay_count:10
redis_muc_delay_max:2.532
redis_muc_delay_min:2.532
redis_muc_delay_avg:2.532
redis_muc_delay_count:1
redis_privacy_delay_max:0.409
redis_privacy_delay_min:0.409
redis_privacy_delay_avg:0.409
redis_privacy_delay_count:1
redis_resource_delay_max:12.012
redis_resource_delay_min:2.101
redis_resource_delay_avg:2.8434699999999986
redis_resource_delay_count:100
redis_group_msg_delay_max:10.342
redis_group_msg_delay_min:2.089
redis_group_msg_delay_avg:2.771269999999999
redis_group_msg_delay_count:100
```

## `install_release.erl`

热更使用，一般不直接使用

## `install_release.sh`

参数：待续
用途：热更

## `route_msg_id.erl`

参数：待续
用途：待续
