# ERL_TOOL 运维工具集


## 基本使用方法

```
./erl_expect -sname <your_node_name>@<your_host_name> <script name>
```

例如

```
/erl_expect -noecho -sname msync@ebs-ali-beijing-msync1 common/monitor3.erl
```

参数

 - `-noecho` 不会显每条执行的命令
 - `-echo` 回显每条命令的执行结果
 - `-setcookie` 设置 cookie ，保证连接


## 常用的脚本

### `common/check_memory_binary.erl` 检查 erlang binary 内存泄露

* 参数 ：
   - N ： 显式 top N 个使用 binary 内存的进程信息，可选，默认 10。
* 功能 ：检查 binary 的内存使用情况
* 例子 :

```
./erl_expect -noecho -sname msync@ebs-ali-beijing-msync1 -setcookie XXXXXXXX common/check_memory_binary.erl 3
total binary = 2.4298200607299805 Mb; 
Pid = <7094.1598.0>, Size = 1.18951416015625 Mb, Info = [ekaf_sup,
                                                         {current_function,
                                                          {gen_server,loop,6}},
                                                         {initial_call,
                                                          {proc_lib,init_p,
                                                           5}}]
Pid = <7094.1777.0>, Size = 0.009746551513671875 Mb, Info = [{current_function,
                                                              {gen_fsm,loop,
                                                               7}},
                                                             {initial_call,
                                                              {proc_lib,
                                                               init_p,5}}]
Pid = <7094.1776.0>, Size = 0.009746551513671875 Mb, Info = [{current_function,
                                                              {gen_fsm,loop,
                                                               7}},
                                                             {initial_call,
                                                              {proc_lib,
                                                               init_p,5}}]
```

### `common/check_memory_heap.erl` 检查 erlang 进程的普通内存使用情况

* 参数 ：
   - N ： 显式 top N 个使用 binary 内存的进程信息，可选，默认 10。
* 功能 ：检查 heap 的内存使用情况
* 例子 :

```
[easemob@ebs-ali-beijing-console erl_tool]$ ./erl_expect -noecho -sname msync@ebs-ali-beijing-msync1 -setcookie XXXXXXXX common/check_memory_heap.erl 3
{<7094.1598.0>,1580384,
 [{registered_name,ekaf_sup},
  {initial_call,{proc_lib,init_p,5}},
  {message_queue_len,0},
  {current_stacktrace,[{gen_server,loop,6,
                                   [{file,"gen_server.erl"},{line,382}]},
                       {proc_lib,init_p_do_apply,3,
                                 [{file,"proc_lib.erl"},{line,240}]}]}]}
{<7094.3205.0>,1222376,
 [{registered_name,msync_c2s},
  {initial_call,{proc_lib,init_p,5}},
  {message_queue_len,0},
  {current_stacktrace,[{gen_server,loop,6,
                                   [{file,"gen_server.erl"},{line,382}]},
                       {proc_lib,init_p_do_apply,3,
                                 [{file,"proc_lib.erl"},{line,240}]}]}]}
{<7094.1485.0>,601920,
 [{registered_name,user},
  {initial_call,{group,server,3}},
  {message_queue_len,0},
  {current_stacktrace,[{group,server_loop,3,
                              [{file,"group.erl"},{line,113}]}]}]}
```

### `common/monitor3.erl` 检查 erlang 进程堆积情况

* 参数 ：
   - N ： 显式 top N 个进程堆积的消息可选，默认 10。
* 功能 ：进程堆积情况和系统信息
* 例子 :

```
[easemob@ebs-ali-beijing-console erl_tool]$ ./erl_expect -noecho -sname msync@ebs-ali-beijing-msync1 -setcookie EASEMOBAAAAAAAAAAEBS common/monitor3.erl 3
LIMIT process_count = 1600
LIMIT process_limit = 4194304
LIMIT port_count = 30979
LIMIT port_limit = 1048576
LIMIT build_type = opt
MEM total = 205910.6008529663 M
MEM processes = 86.6336898803711 M
MEM processes_used = 86.61495208740234 M
MEM system = 205823.96716308594 M
MEM atom = 1.7052545547485352 M
MEM atom_used = 1.6992969512939453 M
MEM binary = 205618.66123962402 M
MEM code = 58.05540466308594 M
MEM ets = 7.2806396484375 M
MAXQUEUELEN  0 PID <7094.23800.1359>
MESSAGE_INITIAL_CALL  <7094.23800.1359> {proc_lib,init_p,5}
CALL_STACK  <7094.23800.1359> : {current_stacktrace,
                                 [{p1_mysql_recv,loop,1,
                                   [{file,"src/p1_mysql_recv.erl"},
                                    {line,124}]}]}
MEMORY  <7094.23800.1359>  2664
STATUS  <7094.23800.1359>  waiting
```


## 编写脚本

脚本的内容是 erlang expressions ，不是 erlang form 。所以不支持 module ， function 等等定义。
也就是说。

内置变量

- `Args` 用户执行脚本的时候，输入的参数。
