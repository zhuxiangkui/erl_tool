% input: UserDomain, RunMode
%
% op: filter and delete msg according to given keyword
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/delete_special_msg.erl UserDomain RunMode

echo(off),

%% To0: musically#musically_n_100000240237219840@easemob.com
%% RunMode: delete | dry_run

[To0, RunMode] = Args,
To = list_to_binary(To0),
%io:format("To: ~p~n", [To]),
CidMidList = message_store:get_messages_index(To, undefined),
%io:format("CidMidList: ~p~n", [CidMidList]),
FilterStr1 = <<"Congratulations!!!\n\nMusical.ly reaches 100 million users. \n\nWe would like to express our sincere thanks and appreciation to our small and efficient team but also to everyone who supported us all this years, especially YOU!">>,
FilterStr2 = <<"We are sorry to inform you that your last verification attempt was unsuccessful.\n\nPlease retry by visiting www.MuserVoice.com and resubmitting your application.">>,
lists:foreach(
    fun({Cid, Mid}) ->
        case message_store:read_message(Mid) of
            not_found ->
                ignore;
            Body ->
                %io:format("Body: ~p~n", [Body]),
                case binary:match(Body, [FilterStr1, FilterStr2]) of
                    nomatch ->
                        ignore;
                    _ ->
                        io:format("[Deleted]: Mid: ~p, Body: ~p~n", [Mid, Body]),
                        case RunMode of
                            "delete" ->
                                message_store:delete_message(To, undefined, Cid, Mid);
                            "dry_run" ->
                                ignore;
                            _ ->
                                ignore
                        end
                end
        end
    end, CidMidList).
