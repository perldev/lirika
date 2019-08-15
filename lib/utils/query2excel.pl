#!/usr/bin/perl
use strict;
use lib q[/usr/local/www/lib];
use warnings;
use SiteDB;
use SiteCommon;
use SiteConfig;
require Spreadsheet::WriteExcel::Simple;
my $ss = Spreadsheet::WriteExcel::Simple->new;
database_connect();
my $q=shift;
my $file=shift;
my $sth=$dbh->prepare($q);
$sth->execute();
while( my $row=$sth->fetchrow_arrayref() ){
	
	foreach(@$row){
		$_=my_decode($_);
	}
	$ss->write_row($row);

}
$ss->save($file) or die $!;

$sth->finish();
database_disconnect();
