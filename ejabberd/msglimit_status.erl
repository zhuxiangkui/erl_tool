% input: AppKey Speed
%
% op: get message limit status
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/msglimit_status.erl

echo(off),
mod_message_limit:status(),
ok.
