% input: none
%
% op: 
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd' common/check_allocator.erl
%       1492601121184,temp_alloc_i0_calls_1_sys_realloc_2,0
%		1492601121184,temp_alloc_i0_calls_1_sys_realloc_1,0 
%       ...

Allocators = [
              {temp_alloc,"Allocator used for temporary allocations."},
              {eheap_alloc,"Allocator used for Erlang heap data, such as Erlang process heaps."},
              {binary_alloc,"Allocator used for Erlang binary data."},
              {ets_alloc,"Allocator used for ETS data."},
              {driver_alloc,"Allocator used for driver data."},
              {sl_alloc,"Allocator used for memory blocks that are expected to be short-lived."},
              {ll_alloc,"Allocator used for memory blocks that are expected to be long-lived, for example Erlang code."},
              {fix_alloc,"A fast allocator used for some frequently used fixed size data types."},
              {std_alloc,"Allocator used for most memory blocks not allocated via any of the other allocators described above."},
              {sys_alloc,"This is normally the default malloc implementation used on the specific OS."},
              {mseg_alloc,"A memory segment allocator"}],
BuildNames =
fun(Names) ->
        string:join(lists:map(fun erlang:atom_to_list/1, lists:reverse(Names)), "_")
end,

Record2Plist1 =
fun Record2PlistFun(Atom, _Names, Acc)
      when is_atom(Atom) ->
        Acc;
    Record2PlistFun(Number, Names, Acc)
      when is_integer(Number) ; is_float(Number) ->
        [{ BuildNames(Names), Number} | Acc];
    Record2PlistFun(Record, _Names, Acc)
      when is_tuple(Record) , element(1,Record) == versions ->
        Acc;
    Record2PlistFun(Record, _Names, Acc)
      when is_tuple(Record) , element(1,Record) == name ->
        Acc;
    Record2PlistFun(Record, Names, Acc)
      when is_tuple(Record) , is_atom(element(1,Record)) ->
        Name = element(1,Record) ,
        lists:foldl(
          fun(I, AccInner) ->
                  NewNames = [list_to_atom(integer_to_list(I)), Name | Names],
                  NewElement = erlang:element(I + 1, Record),
                  Record2PlistFun(NewElement, NewNames, AccInner)
          end, Acc, lists:seq(1, erlang:size(Record) - 1));
    Record2PlistFun(List, Names, Acc)
      when is_list(List) ->
        lists:foldl(
          fun(Elt, AccInner) ->
                  Record2PlistFun(Elt, Names, AccInner)
          end, Acc, List)
end,
Results =
lists:flatmap(
  fun({Allocator, _Info}) ->
          lists:flatmap(fun
                            ({erts_mmap, Info}) ->
                               Record2Plist1(Info, [ erts_mmap, Allocator], []);
                            ({instance, N, Info}) ->
                               Record2Plist1(Info, [ list_to_atom("i" ++ integer_to_list(N)), Allocator], [])
                       end, erlang:system_info({allocator, Allocator}))
  end, Allocators),

Now = os:system_time(milli_seconds),
lists:foreach(
  fun({Name, Value}) ->
          io:format("~p,~s,~p\n",[Now, Name,Value])
  end, Results),
ok.
