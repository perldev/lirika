#!/usr/bin/perl
use strict;
use Data::Dumper;
use RHP::Timer;
use lib q[/usr/local/www/lib];
use SiteDB;
use Storable qw(&thaw);

database_connect('fsb','root','ada13');
my $rates_prev={uah=>0.1369,eur=>1.26027};
my $rates={uah=>0.125,eur=>1.3171 };

my $client=$dbh->selectall_arrayref(q[SELECT a_name,a_id FROM accounts WHERE a_status='active' AND a_acid=2]);
my $credit=$dbh->selectall_arrayref(q[SELECT a_name,a_id FROM accounts WHERE a_status='active' AND a_acid=17]);
my $material=$dbh->selectall_arrayref(q[SELECT a_name,a_id FROM accounts WHERE a_status='active' AND a_acid=4]);

my $all=$dbh->selectall_hashref(q[SELECT a_name,a_id FROM accounts WHERE a_status='active' AND a_acid IN (4,2,17)],'a_id');

my %prev=%{thaw ($dbh->selectrow_array(q[SELECT cr_xml_detailes FROM reports_without WHERE cr_id=108]) ) };
my %this=%{thaw ($dbh->selectrow_array(q[SELECT cr_xml_detailes FROM reports_without WHERE cr_id=620]) ) };

my $rev=$prev{permanent_cards};
my %res=();
foreach my $tmp (@$rev){
	

	
	if($tmp->{plus_column}->{a_id}){
		my $aid=$tmp->{plus_column}->{a_id};
		$res{ $aid }={}	unless($res{ $aid } );
		
		$res{ $aid }->{prev}={};
		$tmp->{plus_column}->{a_usd}=~s/[  \t]//g;
		$tmp->{plus_column}->{a_eur}=~s/[  \t]//g;
		$tmp->{plus_column}->{a_uah}=~s/[  \t]//g;
		$res{ $aid }->{prev}->{amnt}=$rates_prev->{uah}*$tmp->{plus_column}->{a_uah}+$rates_prev->{eur}*$tmp->{plus_column}->{a_eur}+$tmp->{plus_column}->{a_usd} ;
		
	}
	
	if($tmp->{mines_column}){
		my $aid=$tmp->{mines_column}->{a_id};

                $res{ $aid }={} unless($res{ $aid } );

		$res{ $aid }->{prev}={};
                $tmp->{mines_column}->{a_usd}=~s/[  \t]//g;
                $tmp->{mines_column}->{a_eur}=~s/[  \t]//g;
                $tmp->{mines_column}->{a_uah}=~s/[  \t]//g;
                $res{ $aid }->{prev}->{amnt}=$rates_prev->{uah}*$tmp->{mines_column}->{a_uah}+$rates_prev->{eur}*$tmp->{mines_column}->{a_eur}+$tmp->{mines_column}->{a_usd};
                
	}
}
$rev=$this{permanent_cards};
foreach my $tmp (@$rev){
	

        if($tmp->{plus_column}){
		my $aid=$tmp->{plus_column}->{a_id};

                $res{ $aid }={} unless($res{ $aid } );

                $res{ $aid }->{this}={};
                $tmp->{plus_column}->{a_usd}=~s/[  \t]//g;
                $tmp->{plus_column}->{a_eur}=~s/[  \t]//g;
                $tmp->{plus_column}->{a_uah}=~s/[  \t]//g;
                $res{ $aid }->{this}->{amnt}=$rates->{uah}*$tmp->{plus_column}->{a_uah}+$rates->{eur}*$tmp->{plus_column}->{a_eur}+$tmp->{plus_column}->{a_usd};
               
        }

        if($tmp->{mines_column}){
		my $aid=$tmp->{mines_column}->{a_id};

                $res{ $aid }={} unless($res{$aid} );

                $res{ $aid }->{this}={};
                $tmp->{mines_column}->{a_usd}=~s/[  \t]//g;
                $tmp->{mines_column}->{a_eur}=~s/[  \t]//g;
                $tmp->{mines_column}->{a_uah}=~s/[  \t]//g;
                $res{ $aid }->{this}->{amnt}=$rates->{uah}*$tmp->{mines_column}->{a_uah}+$rates->{eur}*$tmp->{mines_column}->{a_eur}+$tmp->{mines_column}->{a_usd};
               
        }
}

my ($sum1,$sum2)=(0,0);

foreach my $t(@$client){
	my $amnt_prev=0;
	my $amnt=0;
	$amnt_prev=$res{$t->[1]}->{prev}->{amnt} if( $res{ $t->[1] }->{prev}); 
	$amnt=$res{$t->[1]}->{this}->{amnt} if( $res{ $t->[1] }->{this});
	print "$t->[0];$amnt_prev;$amnt\n";
	$sum1+=$amnt_prev;
	$sum2+=$amnt;

}
print "Concl;$sum1;$sum2\n";

$sum1=0;
$sum2=0;

print "Credit Card\n";
foreach my $t(@$credit){
        my $amnt_prev=0; 
        my $amnt=0;
        $amnt_prev=$res{$t->[1]}->{prev}->{amnt} if( $res{ $t->[1] }->{prev});
        $amnt=$res{$t->[1]}->{this}->{amnt} if( $res{ $t->[1] }->{this});
        print "$t->[0];$amnt_prev;$amnt\n";
        $sum1+=$amnt_prev;
        $sum2+=$amnt;

}
print "Concl;$sum1;$sum2\n";
$sum1=0;
$sum2=0;
print "Material Card\n";
foreach my $t(@$material){
        my $amnt_prev=0;
        my $amnt=0;
        $amnt_prev=$res{$t->[1]}->{prev}->{amnt} if( $res{ $t->[1] }->{prev});
        $amnt=$res{$t->[1]}->{this}->{amnt} if( $res{ $t->[1] }->{this});
        print "$t->[0];$amnt_prev;$amnt\n";
        $sum1+=$amnt_prev;
        $sum2+=$amnt;

}
print "Concl;$sum1;$sum2\n";
$sum1=0;
$sum2=0;















database_disconnect();
