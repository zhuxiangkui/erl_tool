% input: none
%
% op: garbage collection for all process
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-1 -setcookie secret common/gc.erl
%  

lists:foreach(
  fun(Pid) ->
	  catch erlang:garbage_collect(Pid)
  end, erlang:processes()),
ok.
