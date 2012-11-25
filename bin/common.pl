use Sys::Syslog;
Sys::Syslog::setlogsock('unix');

if (! defined $config->{'logfacility'}){
	$config->{'logfacility'} = 'user';
}
openlog($config->{'program'},'cons,pid', $config->{'logfacility'});

sub notify {
  my($severity, $mesg, $who, $longmsg) = @_;
  $mesg =~ s/\%//g;
  if (! $who) {
    $who = "";
  }
  if (! $longmsg) {
    $longmsg = $mesg;
  }
  $longmsg =~ s/\%//g;
  my($useverity) = uc($severity);

  my($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  $year += 1900;
  $mon += 1;
  my($timestamp) = sprintf("%02d-%02d %02d:%02d:%02d", $mon, $mday, $hour, $min, $sec);
  my($pid) = $$;

  if ($severity eq "debug") {
    if ($config->{'DEBUG'}) {
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

1;
