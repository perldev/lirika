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
    database_disconnect
    database_connect
); #exported subs

our $dbh;
our $TIMER;

sub sql_val{
  my $val = shift;
  #return "NULL" unless(defined $val);
  return $dbh->quote($val);
}
sub database_disconnect{
     $dbh->disconnect();

}
sub database_connect{
    my $dbb=shift;
    my $usdb=shift;
    my $pasd=shift;
   
     if($dbb){
	$db_name=$dbb;
   }

    if($usdb){
        $db_user=$usdb;
	$db_pass=$pasd;
    }



    my $dsn = "DBI:mysql:host=$db_host;database=$db_name";
    $dbh=DBI->connect($dsn, $db_user, $db_pass, { RaiseError => 1});
    $dbh->do("SET charset cp1251;");
    $dbh->do("SET names   cp1251;"); 
    $dbh->do("SET sql_mode = '';"); 
    $dbh->{mysql_auto_reconnect}=1; 
    return $dbh;

}



BEGIN {
#    $TIMER  = RHP::Timer->new();
#    $TIMER->start('fizzbin');    $TIMER->start('fizzbin');                                                                               
    


};


1;
