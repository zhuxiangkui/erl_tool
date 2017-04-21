% input: Vsn
%
% op: remove release
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/remove_release.erl 16.11.2.0

echo(on),
[Vsn] = Args,
try  release_handler:remove_release(Vsn) of
     ok ->
        "GOOD";
     Else ->
        Else
catch
    Class:Error -> {Class, Error}
end.
