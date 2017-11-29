% input: AppKey Pay Email PhoneNumber
%
% op: open image audit for AppKey
% AppKey: user appkey
% Pay: the pay money after open service
% Email: email
% PhoneNumber: phone number
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/open_image_audit.erl AppKey 0 test@email.com 13800000000

echo(off),
[AppKey0, Pay0, Email0, PhoneNumber0] = Args,
AppKey = iolist_to_binary(AppKey0),
PhoneNumber = iolist_to_binary(PhoneNumber0),
Email = iolist_to_binary(Email0),
Pay = iolist_to_binary(Pay0),
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
