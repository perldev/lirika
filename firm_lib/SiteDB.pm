package SiteDB;
use strict;
use warnings;
use DBI;
use SiteConfig;


use Exporter;
our @ISA = ("Exporter");

our @EXPORT = qw(
	$dbh 
	sql_val
); #exported subs

our $dbh;

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
    	


};

END{
    $dbh->disconnect;
}
1;
