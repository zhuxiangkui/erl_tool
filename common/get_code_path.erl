
% input: Module
%
% op: ejabberd / msync version
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/status.erl

echo(off),
[ModuleBinary] =  Args,
Module = list_to_atom(ModuleBinary),
{_M, _B, Path} = code:get_object_code(msync),
io:format("~p ~n", [Path]).
