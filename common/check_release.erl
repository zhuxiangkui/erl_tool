% input: none
%
% op: look up release_Vsn
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd' common/check_release.erl
%       [{"ejabberd","16.11.2.0",
%        ...

echo(on),
release_handler:which_releases().
