
%% input: Vsn
%%
%% op: upgrade to release version Vsn
%%
%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/upgrade_release.erl Vsn


echo(off),
case Args of
    [Vsn, DefaultPath] ->
        ok;
    [Vsn] ->
        DefaultPath = "/data/apps/opt"
end,
release_handler:remove_release(Vsn).
