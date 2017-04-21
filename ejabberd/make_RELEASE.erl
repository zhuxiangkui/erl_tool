% input: Vsn
%
% op: create Release File for Downgrade version
%
% e.g.: ./erl_expect -sname ejabberd@ejabberd-worker -setcookie 'ejabberd' ejabberd/make_RELEASE.erl 16.11.0.1

echo(off),
[Vsn] = Args,
RootDir = code:root_dir(),
Releases = RootDir ++ "/releases/",
RelFile = Releases ++ Vsn ++ "/ejabberd.rel",
release_handler:create_RELEASES(RootDir, Releases, RelFile, []).
