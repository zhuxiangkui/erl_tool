% input: AppKey Pay
%
% op: image audit charge money for AppKey
% AppKey: user appkey
% Pay: the pay money after open service
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/image_audit_charge.erl AppKey 1000

echo(off),
[AppKey0, Pay0] = Args,
AppKey = iolist_to_binary(AppKey0),
Pay = iolist_to_binary(Pay0),
Res = case easemob_image_audit:payment_service(AppKey, Pay) of
          {ok,#{<<"code">> := <<"0">>}} ->
              ok;
          {ok, ResJson} ->
              {error,ResJson};
          {error, Reason} ->
              {error, Reason}
      end,
io:format("Res:~p~n",[Res]),
ok.
