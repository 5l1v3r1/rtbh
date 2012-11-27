#!/usr/bin/perl -w

use strict;
local $| = 1;

our $config;
my($rtbh_home) = $ENV{'HOME'} . "/rtbh";
require "${rtbh_home}/bin/common.pl";

my(%bldomains);
while(<>){
  next if (/(^#)|(^\;)/);
  chomp;
  s/\"//g;
  my($domain);
  if (/\,/){
    my(@flds) = split(/\,/);
    my($phishid, $url, $detail, @junk) = @flds;
    $domain = $url;
    $domain =~ s/^(http|ftp|https):\/\///g;
    $domain =~ s/\/.*//g;
  } else {
    my(@flds) = split(/\t/);
    my($init, $nextvalidation, $dom, $type, @junk) = @flds;
    $domain = $dom;
    $domain =~ s/^\s+//g;
    $domain =~ s/\s+$//g;
  }
  $bldomains{$domain}++;
}

for my $d (sort keys %bldomains){
  next if ($d =~ /\d+(\.\d+){3}/);
  $d =~ s/\.$//g;
  print <<LLI;
"${d}.","redirect"
LLI
}
