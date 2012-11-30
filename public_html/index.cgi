#!/usr/bin/perl

print "Content-type: text/html\n\n";

my($vhost) = $ENV{"HTTP_HOST"};
my($searchdir) = "/home/rpaditya/rtbh/etc/domain/";

print <<LLI;
<h3> ${vhost} </h3>

LLI

my($match) = `/usr/bin/grep ${vhost} ${searchdir}/*.txt ${searchdir}/*.csv` . "\n\n";

if ($match ne ""){
  print <<LLO;
<pre>${match}</pre>
LLO
} else {
  print <<NOV6;
Sorry, ${vhost} cannot be reached from your IPv6 only connection!
NOV6
}
