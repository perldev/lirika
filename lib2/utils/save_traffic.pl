#!/usr/bin/perl
use strict;
#use LWP::UserAgent;
#use RHP::Timer;
use Config;
use lib $path;
use Data::Dumper;
use SiteDB;
use SiteCommon;
my @params;
push @params,shift;
push @params,shift;
# die Dumper \@params;
my $str=$params[0];
my @fids=split(/,/,$str);
$str=join ',',@fids;

my $common_aids_in=$dbh->selectall_hashref(qq[SELECT a_id,a_name,sum(ct_amnt) as s  FROM cashier_transactions,firms,accounts WHERE ct_aid=a_id  AND  ct_fid=f_id   AND ct_fid IN ($str) AND ct_status IN ('created','processed') AND ct_amnt>0 AND MONTH(ct_date)=$params[1]  AND YEAR(ct_date)=YEAR(current_timestamp) 
AND ct_currency='UAH' GROUP BY ct_aid],'a_id');
my $common_aids_out=$dbh->selectall_hashref(qq[SELECT a_id,a_name,sum(ct_amnt) as s  FROM cashier_transactions,firms,accounts WHERE ct_aid=a_id  AND  ct_fid=f_id  AND ct_fid IN ($str) AND ct_status IN ('created','processed') AND ct_amnt<0 AND MONTH(ct_date)=$params[1]   AND YEAR(ct_date)=YEAR(current_timestamp) 
AND ct_currency='UAH' GROUP BY ct_aid],'a_id');

my $common_fids_in=$dbh->selectall_hashref(qq[SELECT f_id,f_name,sum(ct_amnt) as s  FROM cashier_transactions,firms,accounts WHERE ct_aid=a_id  AND  ct_fid=f_id   AND ct_fid IN ($str) AND ct_status IN ('created','processed') AND ct_amnt>0 AND MONTH(ct_date)=$params[1] AND YEAR(ct_date)=YEAR(current_timestamp) 
AND ct_currency='UAH' GROUP BY ct_aid],'f_id');
my $common_fids_out=$dbh->selectall_hashref(qq[SELECT f_id,f_name,sum(ct_amnt) as s  FROM cashier_transactions,firms,accounts WHERE ct_aid=a_id  AND  ct_fid=f_id  AND ct_fid IN ($str) AND ct_status IN ('created','processed') AND ct_amnt<0 AND MONTH(ct_date)=$params[1]  AND YEAR(ct_date)=YEAR(current_timestamp) 
AND ct_currency='UAH' GROUP BY ct_aid],'f_id');

print "\nПо фирмам: \n";
print "Расходы :\n";
my @keys=keys %$common_fids_out;
@keys=sort @keys;

foreach(@keys){

    print "$common_fids_out->{$_}->{f_name}\t$common_fids_out->{$_}->{s}\n";

}
print "\n Приходы : \n";


@keys=keys %$common_fids_in;                                                                                                                             
@keys=sort @keys; 
foreach(@keys){

    print "$common_fids_in->{$_}->{f_name}\t$common_fids_in->{$_}->{s}\n";

}
print "\nПо Клиентам: \n";
print "Расходы :\n";

@keys=keys %$common_aids_out;                                                                                                                                 
@keys=sort @keys; 

foreach(@keys){

    print "$common_aids_out->{$_}->{a_name}\t$common_aids_out->{$_}->{s}\n";

}
print "\n Приходы : \n";
@keys=keys %$common_aids_in;                                                                                                                                 
@keys=sort @keys;
foreach(@keys){

    print "$common_aids_in->{$_}->{a_name}\t $common_aids_in->{$_}->{s}\n";

}
print "\n";


