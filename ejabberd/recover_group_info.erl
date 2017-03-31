%%================================================
%%op:
%%splicing information of group into curl (RestAPI)
%%
%%
%%input:
%%userinfo_file:user_json.txt
%%gourpinfo_file: data.csv
%%
%%output:
%%curl_file:new_data.dat
%%
%%e.g.: 1.Choose a Target ejabberd node
%%      2.copy the user_json.txt and data.csv to /data/apps/opt/ejabberd/ on the node which is choosed
%%      3../erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/recover_group_info.erl
%%================================================

echo(off),

{ok,Binjson} = file:read_file("/data/apps/opt/ejabberd/users_json.txt"),
Enjson = jsx:decode(Binjson),

%%readfile and split content with \n
Readfile=
fun(Filename) ->
	{_,BinStr} = case file:read_file(Filename) of
		     		{ok,Bin}->{ok,Bin};
		     		Error->Error
		 			end,
    Strstr = binary:bin_to_list(BinStr),
    Linestr = string:tokens(Strstr,"\n")
end,

Binstr = Readfile("/data/apps/opt/ejabberd/data.csv"),

List2format=
fun List2formatN([],L) ->
	L;
	List2formatN([H|T],L) ->
	case T of
		[]	->List2formatN(T,["\""++H++"\""|L]);
		_	->List2formatN(T,[",\""++H++"\""|L])
	end
end,

Mergestr=
fun(H,Json) ->
	[V1,V2,V3,V4] = string:tokens(H,","),
    %%io:format("~s~n",[V1]),
    {_,Memberlist} = lists:keyfind(erlang:list_to_binary(V1),1,Json),
    UserList = [erlang:binary_to_list(Value) || Value <- Memberlist],
    UserList1 = List2format(lists:reverse(UserList),[]),
    Str=["curl -i -X POST -H \"Authorization: Bearer YWMt39RfMMOqEeKYE_GW7tu81ABCDT71lGijyjG4VUIC2AwZGzUjVbPp_4qRD5k\" \"http://localhost:5280/api/easemob.com/szy/ztjy/groups/\" -d \'{\"id\":\""++V1++"\", \"groupname\":\""++V3++"\", \"desc\":\""++V4++"\", \"public\":true, \"approval\":true, \"maxusers\":500, \"owner\":\""++V2++"\", \"members\":["++UserList1++"]}\'"],
    %%mergestr(T,[[V1++"+"++V2++"+"++V3++"+"++V4]|L]).
	{Str,Json}
end,

{Lisstr,_} = lists:mapfoldl(Mergestr,Enjson,Binstr),
{ok,S} = file:open("/data/apps/opt/ejabberd/new_data.dat",write),
[io:format(S,"~s ~n",StrUser) || StrUser <- Lisstr],
ok.