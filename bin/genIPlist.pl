#!/usr/bin/perl -w

use strict;
local $| = 1;

my(%ips);
while(<>){
	next if (/(^#)|(^\;)/);
	next if (/^Start/);
	chomp;
	my($ip);
	if ($_ =~ /\|/){
		my(@fields) = split(/\|/);
		if ($#fields > 1){
			my($asn, $foo);
			($asn, $foo, $ip) = @fields;
		}
	} elsif ($_ =~ /\,/){
		my(@fields) = split(/\,/);
		my($start, $end, $mask) = @fields;
		if ($end =~ /^http/){
			next;
		}
	} else {
		my(@fields) = split;
		if ($#fields > 1){
			my($start, $end, $mask) = @fields;
			if (
			    $end eq "#" 
			    || $end eq ";"
			    ){
				$ip = $fields[0];
			} else {
				$ip = $start . "/" . $mask;
			}
		} else {
			$ip = $fields[0];
		}
	}
	$ip =~ s/\;.*$//g;
	$ip =~ s/\#.*$//g;
	$ip =~ s/^\s+//g;
	$ip =~ s/\s+$//g;
	if ($ip =~ /\d+(\.\d+){3}\/\d+/){
	} else {
		$ip .= "/32";
	}	
	$ips{$ip}++;
}

for my $i (sort keys %ips){
	print $i . ": " . $ips{$i} . "\n";
}
