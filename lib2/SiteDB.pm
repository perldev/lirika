package SiteDB;
use strict;
use warnings;
use DBI;
use SiteConfig;
use RHP::Timer;


use Exporter;
our @ISA = ("Exporter");

our @EXPORT = qw(
	$dbh 
	sql_val
	$TIMER	
); #exported subs

our $dbh;
our $TIMER;

sub sql_val{
  my $val = shift;
  #return "NULL" unless(defined $val);
  return $dbh->quote($val);
}

BEGIN {
    my $dsn = "DBI:mysql:host=$db_host;database=$db_name";
    $dbh=DBI->connect($dsn, $db_user, $db_pass, { RaiseError => 1});
    $dbh->do("SET charset cp1251;");
    $dbh->do("SET names   cp1251;");
    $TIMER  = RHP::Timer->new();
#    $TIMER->start('fizzbin');    $TIMER->start('fizzbin');                                                                               
    $dbh->{mysql_auto_reconnect}=1; 
    


};

#END{
#    $dbh->disconnect;
#}
1;
