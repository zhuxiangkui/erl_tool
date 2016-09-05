
% input: Module
%
% op: ejabberd / msync version
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_code_path.erl a b/c d
% File Like This
% msync.
% msync_c2s_handler/msync_c2s.
% app_config.

echo(off),
NodeName = erlang:atom_to_binary(node(), utf8),
[_, Domain] = binary:split(NodeName, <<"@">>),
ModuleList = lists:map(fun(ModuleB) ->
                               ModuleBinary = erlang:list_to_binary(ModuleB),
                               case binary:split(ModuleBinary, <<"/">>) of
                                   [ModuleR, ModuleD] ->
                                       {erlang:binary_to_atom(ModuleD, utf8), ModuleR};
                                   _ ->
                                       erlang:binary_to_atom(ModuleBinary, utf8)
                               end
                       end, Args),

lists:foreach(fun({Module, ModuleR}) ->
                  {_M, _B, Path} = code:get_object_code(Module),
                  PathB = list_to_binary(Path),
                  PathR = binary:replace(PathB, erlang:atom_to_binary(Module, utf8), ModuleR),
                  B = <<Domain/binary, ":", PathR/binary>>,
                  io:format("~s~n", [erlang:binary_to_list(B)]);
             (Module) ->
                  {_M, _B, Path} = code:get_object_code(Module),
                  B = <<Domain/binary, ":", (list_to_binary(Path))/binary>>,
                  io:format("~s~n", [erlang:binary_to_list(B)])
          end, ModuleList).
