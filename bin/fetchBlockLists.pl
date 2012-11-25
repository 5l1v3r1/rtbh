#!/usr/bin/perl -w

use strict;
local $| = 1;

our $config;
my($rtbh_home) = $ENV{'HOME'} . "/rtbh";
my($git) = "/usr/local/bin/git --git-dir=${rtbh_home}/.git --work-tree=${rtbh_home}";

require "${rtbh_home}/bin/common.pl";

my($lists);
while(<>){
	next if (/(^$)|(^#)/);
	chomp;
	my($blockUrl) = split;
	$lists->{$blockUrl} = 1;
}

for my $url (keys %{$lists}){
	my($outfile) = $url;
	$outfile =~ s/^\/etc\///;
	$outfile =~ s/\//./g;
	$outfile = ${rtbh_home} . "/etc/" . $outfile;
	if (-r $outfile){
		my($lastfetch) = getFileCreateTime($outfile);
		my($ttl) = 300000;
		my($now) = time;
		my($diff) = $now - $lastfetch;
		if ($diff < $ttl){
			notify('info', "skipping fetch of ${url} fetched $diff secs ago");
			next;
		}
	} else {
		print STDERR `/usr/bin/touch ${outfile}`;
	}
	    notify('info',  " retrieving filter from ${url}");
	    print STDERR  `/usr/bin/fetch -T 10 -o ${outfile} ${url}`;
	    my($logmsg) = "fetched version at " . time;
	if ($outfile =~ /\.bz2$/){
		my $uncompressed_outfile = $outfile;
		$uncompressed_outfile =~ s/\.bz2$//g;
		print STDERR `/bin/rm ${uncompressed_outfile}`;
		print STDERR `/usr/bin/bunzip2 ${outfile}`;
		$outfile = $uncompressed_outfile;
	}
	    print STDERR `${git} diff ${outfile}`;
	    print STDERR `${git} add ${outfile}`;
	    print STDERR `${git} commit -m"${logmsg}" ${outfile}`;
}
