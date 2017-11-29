% input: AppKey
%
% op: open image audit for AppKey
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/open_image_audit.erl AppKey

echo(off),
[AppKey0] = Args,
AppKey = iolist_to_binary(AppKey0),
PhoneNumber = <<"13888888888">>,
Email = <<"noemail@noemail.com">>,
Pay = <<"1000">>,
Res = case easemob_image_audit:apply_service(AppKey, PhoneNumber, Email, Pay) of
          {ok, #{<<"uid">>:=Uid, <<"private_key">>:=PrivateKey} = ResJson} ->
              app_config:set_image_audit_uid(AppKey, Uid),
              app_config:set_image_audit_private_key(AppKey, PrivateKey),
              ok;
          {ok, ResJson} ->
              {error, ResJson};
          {error, Reason} ->
              {error, Reason}
      end,
io:format("Res:~p~n",[Res]),
ok.
