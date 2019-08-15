#!/usr/bin/perl
use strict;
use lib q[/usr/local/www/lib];
use warnings;
use SiteDB;
use SiteCommon;
use SiteConfig;
database_connect();
my $sth=$dbh->prepare(q[SELECT cs_aid,cs_fsid,cs_percent
                        FROM   client_services
                        WHERE  
                        cs_month=MONTH( DATE_SUB( current_timestamp,interval 1 month ) ) 
                        AND 
                        cs_year=YEAR( DATE_SUB( current_timestamp,interval 1 month ) ) ]);
$sth->execute();
my @ar;

while( my $r=$sth->fetchrow_hashref() ){
	$r->{cs_percent}=0	unless($r->{cs_percent});

    push @ar,"($r->{cs_aid},$r->{cs_fsid},$r->{cs_percent})";

}

my $str=join(",",@ar);


$dbh->do(qq[INSERT INTO client_services(cs_aid,cs_fsid,cs_percent) VALUES$str  ON DUPLICATE KEY UPDATE  cs_percent=VALUES(cs_percent) ]) if($str);




