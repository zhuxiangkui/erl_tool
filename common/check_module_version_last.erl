% input: msync | ejabberd
%
% op: check module is last
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-5 common/check_module_version_last.erl
%       true | false

echo(off),

[{_Name, _Vsn, VerApps, permanent}] = release_handler:which_releases(permanent),
[MS_Ver] = lists:filter(fun(Val) -> string:str(Val, "message_store") =/= 0 end, VerApps),

case Args of
    ["ejabberd"] ->
	Path = string:join(["/data/apps/opt/ejabberd/lib/", MS_Ver, "/ebin/"], "");
    ["msync"] ->
	Path = string:join(["/data/apps/opt/msync/lib/", MS_Ver, "/ebin/"], "")
end,

MLs = [MPath || {_Name, MPath} <- code:all_loaded(), is_list(MPath)],
MLMs =lists:filter(fun(Val) -> string:str(Val, "message_store-") =/= 0 end, MLs),

Fun = fun(H) ->
	BeamF = string:substr(H, string:rstr(H, "/") + 1), 
	{ok, {_MName, Md5_beam}} = beam_lib:version(string:join([Path, BeamF], "")), 
	Mod = string:sub_string(BeamF, 1, string:rstr(BeamF, ".") -1), 
	Md5_modu = proplists:get_value(vsn, proplists:get_value(attributes,(erlang:list_to_atom(Mod)):module_info())), 
	Md5_beam /= Md5_modu
end,

RLoad = fun(Paths) ->
		SpeBeamF = string:substr(Paths, string:rstr(Paths, "/") + 1),
		SpeMNames = string:sub_string(SpeBeamF, 1, string:rstr(SpeBeamF, ".") - 1),
		io:format("RLoad Module: ~p~n", [SpeMNames]),
		c:l(erlang:list_to_atom(SpeMNames))
	   end,

List = lists:filter(Fun, MLMs),
case List == [] of
    true ->
	io:format("true~n", []);
    _ ->
	io:format("false, Not Lastest Modules: ~p~n", [List]),
	lists:foreach(RLoad, List)
end,
ok.
