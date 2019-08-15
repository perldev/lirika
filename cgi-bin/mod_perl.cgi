#/usr/bin/perl
use Data::Dumper;
use DBI;
my $dsn = "DBI:mysql:host=localhost;database=fsb";
$dbh=DBI->connect($dsn,'root','ada', { RaiseError => 1});
$dbh->do("SET charset cp1251;");
$dbh->do("SET names   cp1251;");
my $trans=$dbh->selectrow_array(q[SELECT a_name FROM accounts WHERE a_id=589]);
print "Content-Type: text/html\n\n";
print $trans;
=pod
my $sth=$dbh->prepare(q[SELECT * FROM transactions WHERE t_status='system' ]);

$sth->execute();

while(my $r=$sth->fetchrow_hashref())
{
	unless($trans->{ $r->{t_id} })
	{
		$dbh->do( 'INSERT INTO accounts_transfers SET at_tid=?',undef,$r->{t_id} );		
	}	
}
 
$sth->finish();
=cut
$dbh->disconnect;
exit(0);
