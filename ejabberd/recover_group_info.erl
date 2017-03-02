%%================================================
%%op:
%%splicing information of group into curl (RestAPI)
%%
%%
%%input:
%%userinfo_file:user_json.txt
%%gourpinfo_file: data.csv
%%
%%output:
%%curl_file:new_data.dat
%%
%%e.g.: 1.Choose a Target ejabberd node
%%      2.copy the user_json.txt and data.csv to /data/apps/opt/ejabberd/ on the node which is choosed
%%      3../erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' ejabberd/recover_group_info.erl
%%================================================

echo(off),
recover_groupinfo:strcat(),
ok.
