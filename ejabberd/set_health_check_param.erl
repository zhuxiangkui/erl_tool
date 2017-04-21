% input: Time
%
% op: set health check params
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd' ejabberd/set_health_check_param webim

[Service] = Args,

S = binary_to_atom(list_to_binary(Service), latin1),

Base = [
    {health_monitor_period, 60000},
     {health_server, [
         %{host, "ebs-ali-beijing-console4"},
         {host, "123.57.141.188"},
         {port, "8080"},
         {path, "/health"}
         ]},
     {all_checks, [
         health_check_redis,
         health_check_odbc,
         health_check_session,
         health_check_register_users,
         health_check_process_queue,
         health_check_sendmsg,
         health_check_login_send_message,
         health_check_lager
     ]}],
AllServices = #{
    webim =>[{is_webim, true}, {is_conn, false}, 
             {is_worker, false}, {is_imapi, false},
             {is_rest, false}, {is_session, false},
             {is_muc, false}],
    imapi =>[{is_webim, false}, {is_conn, false}, 
             {is_worker, false}, {is_imapi, true},
             {is_rest, false}, {is_session, false},
             {is_muc, false}],
    conn =>[{is_webim, false}, {is_conn, true}, 
             {is_worker, false}, {is_imapi, false},
             {is_rest, false}, {is_session, false},
             {is_muc, false}],
    worker =>[{is_webim, false}, {is_conn, false}, 
             {is_worker, true}, {is_imapi, false},
             {is_rest, false}, {is_session, false},
             {is_muc, false}],
    rest =>[{is_webim, false}, {is_conn, false}, 
             {is_worker, false}, {is_imapi, false},
             {is_rest, true}, {is_session, false},
             {is_muc, false}],
    session =>[{is_webim, false}, {is_conn, false}, 
             {is_worker, false}, {is_imapi, false},
             {is_rest, false}, {is_session, true},
             {is_muc, false}],
    muc =>[{is_webim, false}, {is_conn, false}, 
             {is_worker, false}, {is_imapi, false},
             {is_rest, false}, {is_session, false},
             {is_muc, true}]
},

#{S := Services} = AllServices,

Envs = Base ++ Services,

lists:foreach(
    fun({K,V}) ->
      application:set_env(ejabberd, K, V)
    end, Envs
).
