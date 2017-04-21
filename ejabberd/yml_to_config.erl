% input: none
%
% op: read config from file_yml to file_config
%
% e.g.: ./erl_expect -sname ejabberd@ebs-ali-beijing-5-pri -setcookie secret $ERL_TOOL_PATH/yml_to_config.erl InputFile OutFile

echo(on),
[InputFile, OutputFile] = Args,
{ok, [Result|_]} = p1_yaml:decode_from_file(InputFile, [plain_as_atom]),
{ok, IO1} = file:open(OutputFile, [write]),
io:format(IO1, "~p~n", [Result]),
ok.
