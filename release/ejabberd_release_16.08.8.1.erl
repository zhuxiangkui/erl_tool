% input: none
%
% op: release-16.08.7
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' release/ejabberd_release_16.08.8.erl

echo(off),
ok = config:load_env("/data/apps/opt/ejabberd/etc/ejabberd/message_store.config"),

IsOnlyConn =
application:get_env(ejabberd, is_conn, false) andalso
application:get_env(ejabberd, is_webim, true) == false andalso
application:get_env(ejabberd, is_imapi, true) == false andalso
application:get_env(ejabberd, is_work, true) == false andalso
application:get_env(ejabberd, is_rest, true) == false andalso
application:get_env(ejabberd, is_session, true) == false andalso
application:get_env(ejabberd, is_muc, true) == false,

case IsOnlyConn of
    true ->
        Md5Expired = [<<"aa9425e6be9296dbd86fb3334ebe2d46">>],
        UpdateModules = [ejabberd_c2s];
    false ->
        Md5Expired = [<<"aa9425e6be9296dbd86fb3334ebe2d46">>, <<"eef7cd09b61dc63e1fd1edcf98805565">>],
        UpdateModules = [ejabberd_c2s, app_config]
end,
lists:foreach(fun(Module) ->
                      code:purge(Module),
                      code:load_file(Module)
              end, UpdateModules),
Md5List =
lists:map(fun(Module) ->
                  M1 = Module:module_info(md5),
                  p1_sha:to_hexlist(M1)
          end, UpdateModules),

case IsOnlyConn of
    true ->
        ignore;
    false ->
        ok = ejabberd_config:load_file("/data/apps/opt/ejabberd/etc/ejabberd/ejabberd.yml")
end,
case Md5List == Md5Expired of
    true ->
        io:format("update Ejabberd :~p right, update list:~p ~n", [erlang:node(), UpdateModules]);
    false ->
        io:format("error !!!!! Ejabberd :~p error, update list:~p ~n", [erlang:node(), UpdateModules]),
        exit(upgrade_error)
end.
