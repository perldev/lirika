use strict;
use lib q(./blib);
#use AI::subclust;
use Data::Dumper;
use DBI;
use POSIX;
print "Content-Type: text/html;charset=cp1251\n\n";
my $RELEVENT_MISTAKE=0.75;
my $dsn = "DBI:mysql:host=localhost;database=fsb";

my $dbh=DBI->connect($dsn, 'fsb_user', 'randomnumber', { RaiseError => 1});
$dbh->do("SET names cp1251");
print $dbh->selectrow_array(q[SELECT a_name FROM accounts ]);