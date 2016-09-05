%%%
% 功能：对所有进程强制做内存回收
% 参数：无
% 用例：./erl_expect -sname ejabberd@ebs-ali-beijing-1 -setcookie secret common/gc.erl
%%%
lists:foreach(
  fun(Pid) ->
	  catch erlang:garbage_collect(Pid)
  end, erlang:processes()),
ok.
