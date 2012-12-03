#!/usr/bin/perl -w

use strict;
local $| = 1;

our $config;
my($rtbh_home) = $ENV{'HOME'} . "/rtbh";
require "${rtbh_home}/bin/common.pl";

use Getopt::Std;
my(%opts);
getopts('D:', \%opts); #Values in %opts

if (defined $opts{'H'}) {
  print STDERR <<EOH;
-D debug (0)
-H for help
EOH
  exit;
}

if (defined $opts{'D'}) {
  $config->{'DEBUG'} = $opts{'D'};
} else {
  $config->{'DEBUG'} = 0;
}

$config->{'PRIVOXY'} = "${rtbh_home}/rtbh.action";
my(%blurls);

$config->{'GOLDEN'} = "${rtbh_home}/whitelist.txt";
my(@golden);

use FileHandle;
my $fh = FileHandle->new($config->{'GOLDEN'}, "r");
if (defined $fh) {
  while (<$fh>){
    next if (/(^$)|(^#)/);
    chomp;
    push (@golden, $_);
  }
  undef $fh;       # automatically closes the file
}


my(%bldomains);
while(<>){
  next if (/(^#)|(^\;)/);
  chomp;
  s/\"//g;
  my($domain, $url);
  if (/\,/){
    my(@flds) = split(/\,/);
    my($phishid, $url, $detail, @junk) = @flds;
    $domain = $url;
    $domain =~ s/^(http|ftp|https):\/\///g;
    $domain =~ s/\/.*//g;
    # we add all urls regardless of whether they are in whitelisted domains
    # because they are specific
    $blurls{$url} = $detail;
  } else {
    my(@flds) = split(/\t/);
    my($init, $nextvalidation, $dom, $type, @junk) = @flds;
    $domain = $dom;
    $domain =~ s/^\s+//g;
    $domain =~ s/\s+$//g;
  }
  my($priority) = 1;
  for my $g (@golden){
    notify("debug", "checking ${domain} against ${g}");
    if ($domain =~ /${g}$/){
      $priority--;
      notify("warning", "skipping domain ${domain} (${priority})- was found in the whitelist!");
    }
  }
  if ($priority > 0){
    $bldomains{$domain}++;
  }
}

my $pfh = FileHandle->new($config->{'PRIVOXY'}, "w");
if (defined $pfh) {
  print $pfh <<HEAD;
{+block{rtbh provided site-specific block pattern matches.}}
HEAD
  for my $u (keys %blurls){
    $u =~ s/^(https?|ftp)\:\/\///g;

#    $u =~ s/\*/\\*/g;
#    $u =~ s/\(/\\(/g;
#    $u =~ s/\)/\\)/g;
#    $u =~ s/\]/\\]/g;
#    $u =~ s/\[/\\[/g;
#    $u =~ s/\\/\\\)/g;
#    $u =~ s/\?/\\?/g;
#    $u =~ s/\./\\./g;

# quotemeta escapes dot and / which are used by privoxy
# so use a custom escape function for this instead
#    $u = quotemeta $u;
#
    $u = escapePrivoxy($u);
    print $pfh $u . "\n";
  }
  $pfh->close;
  undef $pfh;       # automatically closes the file
}


for my $d (sort keys %bldomains){
  next if ($d =~ /\d+(\.\d+){3}/);
  $d =~ s/\.$//g;
  print <<LLI;
"${d}.","redirect"
LLI
}

sub escapePrivoxy {
  my($s) = @_;
  $s =~ s/([\\\^\$\*\+\?\@\{\}\[\]\(\)\<\>])/\\$&/g;
  return $s;
}

sub escapebad {
  my $string = $_[0];
  $string =~ s/([\\\/\^\.\$\*\+\?\@\{\}\[\]\(\)\<\>])/\\$&/g;
  #bad chars turned good
  return ($string);
}
