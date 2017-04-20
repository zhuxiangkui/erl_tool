% input: AppKey, ConfigName
%
% op: remove ConfigName for AppKey
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd'  common/remove_app_config.erl easemob-demo#chatdemoui check_nickname
%		remove check_nickname for easemob-demo#chatdemoui succeed

echo(off),

case Args of
    [RawAppKey, RawConfigName] ->
        AppKey = iolist_to_binary(RawAppKey),
        ConfigName = list_to_atom(RawConfigName),
        case app_config:remove_app_config_global(AppKey, ConfigName) of
            ok ->
                case app_config:remove_app_config(AppKey, ConfigName) of
                    {atomic, _} ->
                        io:format("remove ~s for ~s succeed~n", [ConfigName, AppKey]);
                    _ ->
                        io:format("remove ~s for ~s failed~n", [ConfigName, AppKey])
                end;
            _ ->
                io:format("remove ~s for ~s failed~n", [ConfigName, AppKey])
        end;
    _ ->
        io:format("wrong args: ~p~n", [Args])
end,
ok.
        
    
