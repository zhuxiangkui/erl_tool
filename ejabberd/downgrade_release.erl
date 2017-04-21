% input: Vsn | Vsn Path
%
% op: downgrade vsn of release
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/downgrade_release.erl 16.11.2.0

echo(on),
case Args of
    [Vsn, DefaultPath] ->
        ok;
    [Vsn] ->
        DefaultPath = "/data/apps/opt"
end,

io:format("Args: ~p~n", [Args]),
[{_,OldVsn,_,_}]=release_handler:which_releases(permanent),
io:format("~p ~n",[OldVsn]),
try
  case release_handler:install_release(Vsn, [{suspend_timeout, infinity}, {code_change_timeout, infinity}]) of
      {ok, OtherVsn, []} ->
          release_handler:make_permanent(Vsn),
          io:format("make permanent success ~n"),
          case release_handler:remove_release(OldVsn) of
              ok -> io:format("remove release success ~n"),
       	            "GOOD";
 	      {error,Reason} -> io:format("remove_release failed because ~p~n",[Reason])
          end;	
      Else ->
          io:format("there are something error happened:~p ~n", [Else]),
          exit(-1)
  end
catch
    Class:Error ->
        io:format("exception:~p ~n", [{Class, Error}]),
        exit(-1)
end.
