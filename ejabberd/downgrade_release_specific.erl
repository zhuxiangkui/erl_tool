%% input: VSN
%%
%% op: downgrade to specific_VSN
%%
%% e.g.: ./erl_expect -sname msync@sdb-ali-hangzhou-ejabberd5 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/downgrade_release_specific 17.3.7.0
echo(off),
[Vsn] = Args,

All_releases_opt=release_handler:which_releases(),

All_releases_ht=lists:map(fun({_,E,_,_}) ->E end,All_releases_opt),
[_|All_releases]=All_releases_ht,

Downgrade_FromVsn=
fun(Spe_vsn)->
	io:format("Args:~p ~n", [Spe_vsn]),
	[{_,OldVsn,_,_}]=release_handler:which_releases(permanent),
	try  release_handler:install_release(Spe_vsn, [{suspend_timeout, infinity}, {code_change_timeout, infinity}]) of
     	{ok, OtherVsn, []} ->
        	release_handler:make_permanent(Spe_vsn),
       	 	io:format("make permanent success ~n"),
        	release_handler:remove_release(OldVsn),
        	case release_handler:remove_release(OldVsn) of
          		ok-> io:format("remove release success ~n"),
                  	"GOOD";
            	{error,Reason} -> io:format("remove_release failed because ~p~n",[Reason])
            end,
        	io:format("The current Vsn:~p ~n",[Spe_vsn]),
        	"GOOD";
     	Else ->
        	io:format("there are something error happened:~p ~n", [Else]),
        	exit(-1)
	catch
    	Class:Error ->
        	io:format("exception:~p ~n", [{Class, Error}]),
        	exit(-1)
	end	
end,

case lists:member(Vsn,All_releases) of
	true ->
       Spe_releases=lists:takewhile(fun(E) -> E/=Vsn end,All_releases)++[Vsn],
       io:format("downgrade Vsn sort: ~n"),
       lists:foreach(fun(E) -> io:format(" ~p ~n",[E]) end,Spe_releases),
       lists:foreach(Downgrade_FromVsn,Spe_releases);
	false ->
	   io:format("VSN:~p is fault!")
end,
ok.