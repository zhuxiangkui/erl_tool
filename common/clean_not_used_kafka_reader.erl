% input: none
%
% op: clean not used kafka reader process
%
% e.g.: ./erl_expect -sname ejabberd@sdb-ali-hangzhou-ejabberd3 -setcookie 'LTBEXKHWOCIRRSEUNSYS' common/clean_not_used_kafka_reader.erl


echo(off),
ReaderNames = [element(1,Spec)||Spec<-supervisor:which_children(easemob_kafka_sup)],
ClientIds = easemob_kafka_sup:get_kafka_keys(),
lists:foreach(
  fun(ReaderName) ->
      State = sys:get_state(ReaderName),
      ClientId = element(7,State),
      case string:str(atom_to_list(ReaderName), atom_to_list(ClientId)) of
          0 ->
              %io:format("skip bad client:~p~n",[ClientId]),
              skip;
          _ ->
              case lists:member(ClientId, ClientIds) of
                  false ->
                      io:format("[info] remove bad reader:~p~n",[ReaderName]),
                      supervisor:terminate_child(easemob_kafka_sup, ReaderName),
                      supervisor:delete_child(easemob_kafka_sup, ReaderName),
                      ok;
                  true ->
                      %io:format("skip good reader:~p~n",[ReaderName]),
                      skip
              end
      end
  end,ReaderNames),
ok.
