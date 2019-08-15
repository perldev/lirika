#!/usr/bin/perl
use MyConfig;
use lib $MyConfig::path;
use SiteDB;
use CGIBase;
use SiteCommon;
use strict;
use Storable qw( &nfreeze &thaw );
#this script for restore the accounts state on any date of working the programm
# it creats the table which name looks like account_[number_of_balance]
my $id=shift;#number of balance
database_connect();
my $r=$dbh->selectrow_hashref(q[SELECT * FROM reports_without WHERE cr_id=?],undef,$id);
unless($r->{cr_id}){ 
    die " there is no such id $id\n";
}

my %params = %{thaw($r->{cr_xml_detailes})};
my $permanent_cards=$params{permanent_cards};
$dbh->do(qq[drop table accounts_$id]);
$dbh->do(qq[CREATE table accounts_$id(a_id int primary key,a_name varchar(255),a_uah double(12,2),a_usd double(12,2),a_eur double(12,2) ) default charset cp1251
]);
foreach my $tmp (@$permanent_cards){

    if($tmp->{mines_column}&&$tmp->{mines_column}->{a_id}){
      my $tmp1=$tmp->{mines_column};
      $tmp1->{a_usd}=~s/[ ]//g;
      $tmp1->{a_uah}=~s/[ ]//g;
      $tmp1->{a_eur}=~s/[ ]//g;

      $dbh->do(qq[INSERT INTO accounts_$id(a_id,a_name,a_uah,a_usd,a_eur)  VALUES(?,?,?,?,?)],undef,$tmp1->{a_id},
												$tmp1->{a_name},
												$tmp1->{a_uah},
												$tmp1->{a_usd},
												$tmp1->{a_eur});
    }
    if($tmp->{plus_column}&&$tmp->{plus_column}->{a_id}){
      my $tmp1=$tmp->{plus_column};
      $tmp1->{a_usd}=~s/[ ]//g;
      $tmp1->{a_uah}=~s/[ ]//g;
      $tmp1->{a_eur}=~s/[ ]//g;

      $dbh->do(qq[INSERT INTO accounts_$id(a_id,a_name,a_uah,a_usd,a_eur)  VALUES(?,?,?,?,?)],undef,$tmp1->{a_id},$tmp1->{a_name},
												$tmp1->{a_uah},
												$tmp1->{a_usd},
												$tmp1->{a_eur});
    }

}
