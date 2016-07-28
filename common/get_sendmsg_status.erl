%%--------------------------------------------------------------------
%% @doc common/get_sendmsg_status.erl
%%
%% @spec input: none
%%
%% @spec example: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd4 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/get_sendmsg_status.erl
%%
%% @spec op:
%%
%% @spec result:
%%
%% @end
%%--------------------------------------------------------------------

echo(off),

{ChatQL, GroupChatQL} = mod_easemob_sendmsg:status(<<"easemob.com">>),

lists:foreach(
    fun(ChatQueue) ->
        State = sys:get_state(ChatQueue),
        {state, _Atom, _Easemob, _Redis, _Port, _, QName, {maxrate, Max, Cur, _TimeStamp}, _UpLimit} = State,
        io:format("    ~p, ~p, ~p~n", [binary_to_list(QName), Max, trunc(Cur)])
    end, ChatQL),

lists:foreach(
    fun(GroupChatQueue) ->
        State = sys:get_state(GroupChatQueue),
        {state, _Atom, _Easemob, _Redis, _Port, _, QName, {maxrate, Max, Cur, _TimeStamp}, _UpLimit} = State,
        io:format("    ~p, ~p, ~p~n", [binary_to_list(QName), Max, trunc(Cur)])
    end, GroupChatQL).
