#!/usr/bin/perl
use strict;
use Time::Local;
sub open_file {
    my $filename = shift;
    open(my $fh, '>', $filename) or die "cannot open $filename";
    return $fh;
}
my %all_fd = ();
while (<>) {
    if(/.*hostname=(?<hostname>[A-Za-z-]*[0-9]*).*
       (?<year>[0-9][0-9][0-9][0-9])-(?<month>[0-9][0-9])-(?<day>[0-9][0-9])\s(?<hour>[0-9][0-9]):(?<minute>[0-9][0-9]):(?<second>[0-9][0-9])\.(?<mili>[0-9][0-9][0-9])
       \s+
       \[(?<loglevel>.*)\]
       \s<[0-9.]*>@
       (?<module>[0-9a-zA-Z_]+):
       (?<fun>[0-9a-zA-Z_]+):
       (?<line>[0-9]+)\s
       /xms
        ){
        my $filename  = $+{hostname} .  "." . $+{module} . "." .  $+{fun} . "." . $+{line} . "." . $+{loglevel} . ".log";
        if (not exists $all_fd{$filename} ) {
            $all_fd{$filename} = open_file($filename);
        }
        my $fd = $all_fd{$filename};
        my $m2 = $+{month} - 1;
        my $timestamp = timelocal($+{second},$+{minute},$+{hour},$+{day}, $m2,$+{year});
        my $timestamp2 = $timestamp * 1000 + $+{mili};
        print $fd "$timestamp2\n";
    }
}

for my $key (keys %all_fd) {
    my $fd = $all_fd{$key};
    close $fd;
}
