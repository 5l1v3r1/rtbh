#!/usr/bin/perl -w

use strict;
local $| = 1;

our $config;
use Sys::Syslog;
Sys::Syslog::setlogsock('unix');

if (! defined $config->{'logfacility'}){
	$config->{'logfacility'} = 'user';
}
openlog($config->{'program'},'cons,pid', $config->{'logfacility'});

my($rtbh_home) = $ENV{'HOME'} . "/rtbh";
my($git) = "/usr/local/bin/git --git-dir=${rtbh_home}/.git --work-tree=${rtbh_home}";

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
		print STDERR `/usr/bin/bunzip2 ${outfile}`;
		print STDERR `/bin/rm ${outfile}`;
		$outfile =~ s/\.bz2$//g;
	}
	    print STDERR `${git} diff ${outfile}`;
	    print STDERR `${git} add ${outfile}`;
	    print STDERR `${git} commit -m"${logmsg}" ${outfile}`;
}

    sub notify {
	my($severity, $mesg, $who, $longmsg) = @_;
	$mesg =~ s/\%//g;
	if (! $who){
		$who = "";
	    }
	    if (! $longmsg){
		    $longmsg = $mesg;
		}
		$longmsg =~ s/\%//g;
		my($useverity) = uc($severity);

		my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
		$year += 1900;
		$mon += 1;
		my($timestamp) = sprintf("%02d-%02d %02d:%02d:%02d", $mon, $mday, $hour, $min, $sec);
		my($pid) = $$;

		if ($severity eq "debug"){
			if ($config->{'DEBUG'}){
				print STDERR "${useverity}: ($timestamp): $mesg\n";
			    }
		    } else {
			print STDERR "${useverity}: ($timestamp): $mesg\n";
			syslog($severity, "${useverity}: $mesg");
		    }
    }

sub getFileCreateTime {
	my($f) = @_;
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)
		= stat($f);
	return $mtime;
}
