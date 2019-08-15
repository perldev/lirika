#!/usr/bin/perl
use strict;
use Storable;
use Data::Dumper;
use lib q[/usr/local/www/lib];
use SiteDB;
database_connect();
my $id1=shift;
my $id2=shift;

my $first=$dbh->selectrow_array(q[SELECT cr_xml_detailes  FROM reports_without WHERE cr_id=?],undef,$id1);
my $second=$dbh->selectrow_array(q[SELECT cr_xml_detailes  FROM reports_without WHERE cr_id=?],undef,$id2);


my %params1 = %{Storable::thaw($first)};
print Dumper \%params1;
my %params2 = %{Storable::thaw($second)};


my $hash1={};
my $hash2={};

foreach(@{$params1{permanent_cards}}){
   my $r;
     
   $r=$_->{mines_column};
   $hash1->{$r->{a_id}}={a_uah=>format_float($r->{a_uah}),a_usd=>format_float($r->{a_usd}),a_eur=>format_float($r->{a_eur})};
   $r=$_->{plus_column};
   $hash1->{$r->{a_id}}={a_uah=>format_float($r->{a_uah}),a_usd=>format_float($r->{a_usd}),a_eur=>format_float($r->{a_eur})};

}

foreach(@{$params2{permanent_cards}}){
   

   my $r;
   $r=$_->{mines_column};
   $hash2->{$r->{a_id}}={a_uah=>format_float($r->{a_uah}),a_usd=>format_float($r->{a_usd}),a_eur=>format_float($r->{a_eur})};
   $r=$_->{plus_column};
   $hash2->{$r->{a_id}}={a_uah=>format_float($r->{a_uah}),a_usd=>format_float($r->{a_usd}),a_eur=>format_float($r->{a_eur})};   

}






my $result_hash={};

foreach my $tmp (keys %$hash1){

       my $r1=$hash1->{$tmp}; 

       my $r2=$hash2->{$tmp}; 






      $result_hash->{$tmp}={
                             uah=>$r1->{a_uah}-$r2->{a_uah},
                             eur=>$r1->{a_eur}-$r2->{a_eur},
                             usd=>$r1->{a_usd}-$r2->{a_usd}
                            };
            
}
my @a=sort {                    (abs($result_hash->{$b}->{uah})+abs($result_hash->{$b}->{usd})+abs($result_hash->{$b}->{eur}))<=>(abs($result_hash->{$a}->{uah})+abs($result_hash->{$a}->{usd})+abs($result_hash->{$a}->{eur}))  
    } keys %$result_hash;


my $names=$dbh->selectall_hashref(q[SELECT a_name,a_id FROM accounts],'a_id');

foreach my $tmp (@a){
    print "$names->{$tmp}->{a_name} - uah => $result_hash->{$tmp}->{uah},usd=>$result_hash->{$tmp}->{usd}, eur=>$result_hash->{$tmp}->{eur} \n";
}
print " NEW   \n";
foreach(keys  %$hash2){

  print "$_ - uah => $hash2->{$_}->{a_uah},usd=>$hash2->{$_}->{a_usd}, eur=>$hash2->{$_}->{a_eur} \n"  unless($result_hash->{$_});
}

exit(0);






sub format_float{
    my $r=shift;
    $r=~s/[ ]//g;
    return $r;
}

