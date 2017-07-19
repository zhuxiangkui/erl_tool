%%%
%% Feature:
%% paras:
%% ex: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/check_lager.erl ejabberd
%%
echo(off),
case Args of
    ["ejabberd"] ->
        case lager:get_loglevel({lager_file_backend,"/data/apps/opt/ejabberd/var/log/ejabberd/error.log"}) == error
            andalso lager:get_loglevel({lager_file_backend,"/data/apps/opt/ejabberd/var/log/ejabberd/ejabberd.log"}) == info of
            true ->
                true;
            false ->
                io:format("lager is set by someone Node:~p ~n", [node()])
        end;
    ["msync"] ->
        case lager:get_loglevel({lager_file_backend,"/data/apps/opt/msync/log/error.log"}) == error
            andalso lager:get_loglevel({lager_file_backend,"/data/apps/opt/msync/log/info.log"}) == info of
            true ->
                true;
            false ->
                io:format("lager is set by someone Node:~p ~n", [node()])
        end
end.
