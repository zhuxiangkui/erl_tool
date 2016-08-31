% input: none
%
% op: release-16.08.7
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' release/ejabberd_release_16.08.8.erl

echo(off),
ok = config:load_env("/data/apps/opt/ejabberd/etc/ejabberd/message_store.config"),
case application:get_env(ejabberd, is_conn, false) of
    true ->
        Md5Expired = [<<"78ae11a8a4b7b5552d42aa7b579b3ba9">>],
        UpdateModules = [ejabberd_c2s];
    false ->
        Md5Expired = [<<"78ae11a8a4b7b5552d42aa7b579b3ba9">>, <<"e830c2d8ac9b5ce54b8bc6147bfcc450">>, <<"dacc8cb577de81a69bdc8c200adf5ec9">>, <<"879d96ae66e4186ce80eaf6098975bf9">>, <<"cd3dbbb26acca211447afbad9f21cd4b">>, <<"b8acb962b007bc4c2e1160c1f618ad50">>],
        UpdateModules = [ejabberd_c2s, app_config, easemob_message_body, ejabberd_sm, mod_message_cache, mod_multi_devices]
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
case Md5List == Md5Expired of
    true ->
        io:format("update Ejabberd :~p right, update list:~p ~n", [erlang:node(), UpdateModules]);
    false ->
        io:format("error !!!!! Ejabberd :~p error, update list:~p ~n", [erlang:node(), UpdateModules])
end.
