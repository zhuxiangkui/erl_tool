
%%%
% feature: get configure info from etcd server
% params : Prefix, Appname, Key(option)
% example: ./erl_expect -sname ejabberd@ebs-ali-beijing-88 -setcookie secret common/etcd_config_get.erl "/imstest/vip1/msync/workerconfig/all" "msync" "httpc_timeout"
%          ./erl_expect -sname ejabberd@ebs-ali-beijing-88 -setcookie secret common/etcd_config_get.erl "/imstest/vip1/msync/workerconfig/all" "msync"
% note   : 在某一台msync/ejabberd 节点上执行即可
%%%

echo(off),

FparseKey =
    fun(Key) ->
        erlang:binary_to_atom(filename:basename(Key), latin1)
    end,
Fparsevalue =
    fun(Value) ->
        case erl_scan:string(Value ++ ".") of
            {ok, Tokens, _} ->
                case erl_parse:parse_term(Tokens) of
                    {ok, Term} -> Term;
                    _Err -> undefined
                end;
            _Error ->
                undefined
        end
    end,

EtcdKey0 =
    case Args of
        [Prefix, AppName, Par] ->
            {ok, filename:join([Prefix, AppName, Par])};
        [Prefix, AppName] ->
            {ok, filename:join([Prefix, AppName])};
        _ ->
            {error, args_error}
    end,
Res =
    case EtcdKey0 of
        {ok, EtcdKey} ->
            etcdc:get(EtcdKey, [recursive]);
        {error, Reason} ->
            {error, Reason}
    end,
case Res of
    {error, _Reason} ->
        io:format("~p~n", [Res]);
    #{<<"node">> := #{<<"key">> := SingleKey, <<"value">> := SingleValue}} ->
        io:format("{~p,~p}~n", [FparseKey(SingleKey), Fparsevalue(erlang:binary_to_list(SingleValue))]);
    #{<<"node">> := #{<<"nodes">> := NodeList}} ->
        [begin
            #{<<"key">> := Keyx, <<"value">> := Valuex} = Node,
            io:format("{~p,~p}~n", [FparseKey(Keyx), Fparsevalue(erlang:binary_to_list(Valuex))])
         end || Node <- NodeList]
end,
ok.
