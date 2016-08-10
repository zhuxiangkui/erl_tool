
% input: Module
%
% op: ejabberd / msync version
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_code_path.erl /Users/zhangchao/work/github.com/erl_tool/common/a.txt /Users/zhangchao/work/github.com/erl_tool/common/b.txt
% File Like This
% msync.
% msync_c2s_handler.
% app_config.

echo(off),
[File, OutFile] = Args,
NodeName = erlang:atom_to_binary(node(), utf8),
[_, Domain] = binary:split(NodeName, <<"@">>),
{ok, ModuleList} = file:consult(File),
{ok, FD} = file:open(OutFile, [write, append]),

lists:map(fun(Module) ->
                  {_M, _B, Path} = code:get_object_code(Module),
                  B = <<Domain/binary, ":", (list_to_binary(Path))/binary>>,
                  io:format(FD, "~s~n", [erlang:binary_to_list(B)])
          end, ModuleList).
