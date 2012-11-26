#!/usr/bin/perl -w

use strict;
local $| = 1;

use Net::Subnet;
use FileHandle;

our $config;
my($rtbh_home) = $ENV{'HOME'} . "/rtbh";
require "${rtbh_home}/bin/common.pl";

$config->{'GOLDEN'} = "${rtbh_home}/golden.txt";

my(@golden);

my $fh = FileHandle->new($config->{'GOLDEN'}, "r");
if (defined $fh) {
  while (<$fh>){
    next if (/(^$)|(^#)/);
    chomp;
    push (@golden, $_);
  }
  undef $fh;       # automatically closes the file
}

my $in_golden = subnet_matcher(@golden);

while(<>){
  chomp;
  if ($in_golden->($_)){
    print <<LLI;
# $_ is in golden list
LLI
  } else {
#    print $_ . "\n";
  }
}
