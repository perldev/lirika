#!/usr/bin/perl
use strict;
use MyConfig;
use lib $MyConfig::path;
use SiteDB;
use SiteCommon;
use Data::Dumper;
database_connect();

my $date=$dbh->selectrow_hashref(q[SELECT  DATE(max(sr_date)) as min_date,
				   MONTH(max(sr_date)) as m,DAY( max(sr_date)) as d,YEAR(max(sr_date)) as y FROM system_rates  ]);





my $header_rates=$dbh->selectall_hashref(qq[SELECT DATE(hr_date) as hr_date,hr_rate_street,hr_domi,hr_rate_cross FROM header_rates WHERE  hr_date>DATE('$date->{min_date}') ],'hr_date');



my $dates=generate_set_of_dates_array($date->{d},$date->{m},$date->{y});
my $prev;

unless($prev=$header_rates->{ $dates->[0] } ){

	$prev=$dbh->selectrow_hashref(qq[SELECT DATE(hr_date) as hr_date,hr_rate_street,hr_domi,hr_rate_cross FROM header_rates WHERE hr_date<'$date->{min_date}' ORDER BY hr_date DESC LIMIT 1]);

}


my $current;
foreach(@$dates){

	$current=$header_rates->{$_};
	unless($current->{hr_rate_street}){
		$current->{hr_rate_street}=$prev->{hr_rate_street};

	}

	$current->{hr_rate_street}=~s/[,]/\./;
	$current->{hr_rate_street}=~/(\d+\.\d+)/;
	$current->{hr_rate_street}=$1;
	unless($current->{hr_domi}){
		$current->{hr_domi}=$prev->{hr_domi};

	}

	$current->{hr_domi}=~s/[,]/\./;
        $current->{hr_domi}=~/(\d+\.\d+)/; 
	$current->{hr_domi}=$1;
	
	 unless($current->{hr_rate_cross}){
                $current->{hr_rate_cross}=$prev->{hr_rate_cross};
                

        }


	$current->{hr_rate_cross}=~s/[,]/\./;
	$current->{hr_rate_cross}=~/(\d+\.\d+)/;
        $current->{hr_rate_cross}=$1;
	
	eval{
	$dbh->do(qq[INSERT INTO system_rates(sr_date,sr_uah_nal,sr_uah_domi,sr_eur_nal,sr_eur_domi)  
	           VALUES('$_',1/$current->{hr_rate_street},1/$current->{hr_domi},$current->{hr_rate_cross},$current->{hr_rate_cross}) ]);
	};
	if($@){
		

		die qq[INSERT INTO system_rates(sr_date,sr_uah_nal,sr_uah_domi,sr_eur_nal,sr_eur_domi)
                   VALUES('$_',1/$current->{hr_rate_street},1/$current->{hr_domi},$current->{hr_rate_cross},$current->{hr_rate_cross}) ],Dumper $header_rates->{$_};
	}

	$prev=$current;	
}



exit(0);












