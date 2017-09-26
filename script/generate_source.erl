%% escript generate_source.erl MsyncDir
%% MsyncDir: dir of msync source
%% example: escript generate_source.erl ~/d/working/msync
-module(generate_source).
-export([main/1]).
main([]) ->
    main(".");
main([RootDir]) ->
    main([RootDir, "src"]);
main([RootDir, OutDir]) ->
    c:cd(RootDir),
    BeamDir = "ebin",
    Tag = get_tag(),
    gen_src(BeamDir, OutDir),
    gen_beam(),
    gen_makefile(),
    remove_some_files(),
    gen_git(Tag),
    ok.

gen_beam() ->
    set_debug_info(false),
    clean_files("deps/**/*.beam"),
    clean_files("ebin/*.beam"),
    io:format("~ts~n",[os:cmd("make")]),
    clean_files("deps/im_libs/apps/**/*.erl"),
    clean_files("deps/im_libs/apps/**/*.hrl"),
    ok.

get_tag() ->
    case string:tokens(os:cmd("git describe --always --tags"),"-\r\n") of
        [Tag|_] ->
            Tag;
        _ ->
            "1.0.0"
    end.

gen_makefile() ->
    replace_file("Makefile","; rm -fr deps",""),
    replace_file("Makefile","rm -fr deps",""),
    replace_file("Makefile","all: deps src/fingerprint.erl appups","all: deps src/fingerprint.erl"),
    ok.

set_debug_info(Bool) ->
    replace_file("vars.config", "{debug,[^}]*}", "{debug, "++atom_to_list(Bool)++"}"),
    ok.

replace_file(Filename, From, To) ->
    {ok, Bin} = file:read_file(Filename),
    List = binary_to_list(Bin),
    ListNew = re:replace(List, From, To, [{return,list}]),
    file:write_file(Filename, ListNew),
    ok.

remove_some_files() ->
    clean_files("deps/im_libs/apps/**/*.erl"),
    clean_files("deps/im_libs/apps/**/*.hrl"),
    clean_files("deps/*/ebin/*.beam"),
    clean_files("ebin/*.beam"),
    remove_file_or_dirs("all.txt"),
    remove_file_or_dirs("**/.git"),
    remove_file_or_dirs("**/.rebar"),
    remove_file_or_dirs("previous_release"),
    remove_file_or_dirs("rel/lib"),
    remove_file_or_dirs("rel/releases"),
    remove_file_or_dirs("rel/msync*"),
    io:format("~ts~n",[os:cmd("make clean")]),
    ok.

gen_git(Tag) ->
    io:format("~ts~n",[os:cmd("git init;"
                              "git config --local user.name easemob;"
                              "git config --local user.email easemob@easemob.com;"
                              "git add *;"
                              "git commit -m \""++Tag++"\";"
                              "git tag -a "++Tag++" -m "++Tag++";")]),
    ok.

gen_src(BeamDir, OutDir) ->
    set_debug_info(true),
    clean_files("ebin/*.beam"),
    io:format("~ts~n",[os:cmd("make")]),
    code:add_pathz("deps/recon/ebin"),
    code:add_pathz("ebin"),
    filelib:ensure_dir(OutDir++"/"),
    FileNames = filelib:wildcard(filename:join(BeamDir,"*.beam")),
    lists:foreach(
      fun(FileName) ->
              BaseName = filename:basename(FileName, ".beam"),
              io:format("generate source for:~ts~n", [BaseName]),
              Module = list_to_atom(BaseName),
              Source = recon:source(Module),
              RegionList = [{"-file(", ")."},
                            {"-spec(", ")."},
                            {"-type(", ")."},
                            {"-callback(", ")."},
                            {"-export_type(", ")."}
                           ],
              SourceNew = lists:foldl(
                            fun({Start, End}, TSource) ->
                                    remove_region(TSource, Start, End)
                            end, Source, RegionList),
              OutFile = filename:join(OutDir,BaseName ++ ".erl"),
              file:write_file(OutFile, SourceNew)
      end, FileNames).

remove_region(Str, Start, End) ->
    case string:str(Str, Start) of
        0 -> Str;
        Idx ->
            StrBefore = string:sub_string(Str, 1, Idx-1),
            StrRest = string:sub_string(Str, Idx, length(Str)),
            case string:str(StrRest, End) of
                0 -> throw(bad_str);
                Idx2 ->
                    StrAfter0 = string:sub_string(StrRest, Idx2+length(End), length(StrRest)),
                    StrAfter = lists:dropwhile(
                                 fun (Elem) ->
                                         lists:member(Elem, " \r\n\t")
                                 end, StrAfter0),
                    remove_region(StrBefore++StrAfter, Start, End)
            end
    end.

clean_files(CardStr) ->
    Files = filelib:wildcard(CardStr),
    [file:delete(File)||File<-Files],
    ok.

remove_file_or_dirs(CardStr) ->
    Files = filelib:wildcard(CardStr),
    [os:cmd("rm -rf "++File)||File<-Files],
    ok.
