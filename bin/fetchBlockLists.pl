#!/usr/bin/perl -w

use strict;
local $| = 1;

our $config;
my($rtbh_home) = $ENV{'HOME'} . "/rtbh";
my($git) = "/usr/local/bin/git --git-dir=${rtbh_home}/.git --work-tree=${rtbh_home}";

require "${rtbh_home}/bin/common.pl";

my($lists);
while (<>) {
  next if (/(^$)|(^#)/);
  chomp;
  my($type, $blockUrl) = split;
  $lists->{$blockUrl} = $type;
}

for my $url (keys %{$lists}) {
  my($outfile) = $url;
  my($listType) = $lists->{$url};
  $outfile =~ s/^\/etc\///;
  $outfile =~ s/\//./g;
  my($outdir) = ${rtbh_home} . "/etc/" . $listType;
  if (! -d $outdir) {
    notify("debug", "creating dir ${outdir}");
    print STDERR `/bin/mkdir -p ${outdir}`;
    if ($?) {
      notify("err", "could not mkdir ${outdir}: ${?}");
      next;
    }
  }
  $outfile = $outdir . "/" . $outfile;
  if (-r $outfile) {
    my($lastfetch) = getFileCreateTime($outfile);
    my($ttl) = 300000;
    my($now) = time;
    my($diff) = $now - $lastfetch;
    if ($diff < $ttl) {
      notify('info', "skipping fetch of ${url} fetched $diff secs ago");
      next;
    }
  } else {
    print STDERR `/usr/bin/touch ${outfile}`;
  }
  notify('info',  " retrieving filter from ${url}");
  print STDERR  `/usr/bin/fetch -i ${outfile} -T 10 -o ${outfile} ${url}`;
  my($logmsg) = "fetched version at " . time;

  my(@fileq);
  if ($outfile =~ /\.bz2$/) {
    my $uncompressed_outfile = $outfile;
    $uncompressed_outfile =~ s/\.bz2$//g;
    print STDERR `/usr/bin/bunzip2 -qfk ${outfile}`;
    push(@fileq, $uncompressed_outfile);
  }
  push(@fileq, $outfile);
  for my $f (@fileq){
    print STDERR `${git} add ${f}`;
    print STDERR `${git} diff ${f}`;
    print STDERR `${git} commit -m"${logmsg}" ${f}`;
  }
}
