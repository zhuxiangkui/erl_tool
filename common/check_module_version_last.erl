% input: none
%
% op: check module is last
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-5 common/check_module_version_last.erl
%       true | false

echo(off),

MLs = [MPath || {_Name, MPath} <- code:all_loaded(), is_list(MPath)],
MLMs =lists:filter(fun(Val) -> string:str(Val, "message_store") =/= 0 end, MLs),
Fun = fun(H) -> {ok, {_MName, Md5_beam}} = beam_lib:md5(H), BeamF = string:substr(H, string:rstr(H, "/") + 1), Mod = string:sub_string(BeamF, 1, string:rstr(BeamF, ".") -1), Md5_modu = (erlang:list_to_atom(Mod)):module_info(md5), Md5_beam /= Md5_modu end,
List = lists:filter(Fun, MLMs),
case List == [] of
    true ->
	io:format("true~n", []);
    _ ->
	io:format("false~n", [])
end,
ok.
