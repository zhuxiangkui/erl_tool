%% create Release File for Downgrade version
echo(off),
[Vsn] = Args,
RootDir = code:root_dir(),
Releases = RootDir ++ "/releases/",
RelFile = Releases ++ Vsn ++ "/ejabberd.rel",
release_handler:create_RELEASES(RootDir, Releases, RelFile, []).
