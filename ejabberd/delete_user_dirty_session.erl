%% input: UserSessionKeyFile
%% UserSessionKeyFile: the file that contains all the keys of the user session
%% op: delete user dirty session
%% !!! must copy the UserSessionKeyFile to /data/apps/opt/ejabberd/users-session.data on the target ejabberd node
%% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/delete_user_dirty_session.erl


echo(off),
session_repair:delete_bad_sessions("/data/apps/opt/ejabberd/users-session.data",true,0),
ok.
