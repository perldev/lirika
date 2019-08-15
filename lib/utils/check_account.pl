#!/usr/bin/perl
use strict;
use LWP::UserAgent;
use RHP::Timer;
use Data::Dumper;
use lib q[/usr/local/www/lib];
use SiteDB;
database_connect();
my $aid=shift;
our $TIMER;
$TIMER  = RHP::Timer->new();
$TIMER->start('fizzbin');



my $rows=$dbh->prepare(q[SELECT * FROM accounts_reports_table WHERE 
                          ct_aid=?  
                          AND
                          ct_status!='deleted'
                          AND ct_ex_comis_type='transaction'
                    ]);

$rows->execute($aid);

my @arr;
while(my $r=$rows->fetchrow_hashref()){
    push @arr,$r->{ct_id};
}
$rows->finish();

$rows=$dbh->prepare(q[SELECT * FROM accounts_reports_table,exchange WHERE 
                          ct_id=e_id  
                          AND
                          ct_aid=?  
                          AND
                          ct_status!='deleted'
                          AND ct_ex_comis_type='simple'
                    ]);
$rows->execute($aid);
while(my $r=$rows->fetchrow_hashref()){
    push @arr,$r->{e_tid1};
    push @arr,$r->{e_tid2};
}

$rows->finish();


$rows=$dbh->prepare(q[SELECT ct_tid2,ct_tid2_comis,ct_tid2_ext_com 
                          FROM accounts_reports_table as a,cashier_transactions d WHERE 
                          a.ct_id=d.ct_id  
                          AND
                          d.ct_aid=?  
                          AND
                          a.ct_fid>0
                          AND
                          d.ct_eid  IS NULL 
                          AND
                          a.ct_status!='deleted'
                          AND a.ct_ex_comis_type='input'
                    ]);
$rows->execute($aid);
while(my $r=$rows->fetchrow_hashref()){
    push @arr,$r->{ct_tid2};
    push @arr,$r->{ct_tid2_comis} if($r->{ct_tid2_comis});
    push @arr,$r->{ct_tid2_ext_com} if($r->{ct_tid2_ext_com});
}
$rows->finish();


$rows=$dbh->prepare(q[SELECT ct_tid2,ct_tid2_comis,ct_tid2_ext_com,e_tid1,e_tid2
                          FROM accounts_reports_table as a,cashier_transactions d,exchange WHERE 
                          a.ct_id=d.ct_id  
                          AND
                          d.ct_aid=?  
                          AND
                          a.ct_fid>0
                          AND
                          d.ct_eid=e_id
                          AND
                          a.ct_status!='deleted'
                          AND a.ct_ex_comis_type='input'
                    ]);
$rows->execute($aid);
while(my $r=$rows->fetchrow_hashref()){

    push @arr,$r->{ct_tid2};
    push @arr,$r->{ct_tid2_comis} if($r->{ct_tid2_comis});
    push @arr,$r->{ct_tid2_ext_com} if($r->{ct_tid2_ext_com});
    push @arr,$r->{e_tid1};
    push @arr,$r->{e_tid2};
}

$rows->finish();

    
        $rows=$dbh->prepare(q[SELECT a.ct_id,ct_tid,ct_tid2_comis,ct_tid2_ext_com
                                FROM accounts_reports_table as a,cashier_transactions d WHERE 
                                a.ct_id=d.ct_id  
                                AND
                                d.ct_aid=?  
                                AND
                                d.ct_fid<0
                                AND
                                a.ct_status!='deleted'
                                AND a.ct_ex_comis_type='input'
                            ]);
        $rows->execute($aid);
        while(my $r=$rows->fetchrow_hashref()){
            

            push @arr,$r->{ct_tid} if($r->{ct_tid});
            push @arr,$r->{ct_tid2_comis} if($r->{ct_tid2_comis});
            push @arr,$r->{ct_tid2_ext_com} if($r->{ct_tid2_ext_com});
        }


$rows->finish();
    
my $str=join(',',@arr);


foreach( ('USD','UAH','EUR') ){

	my $s1=$dbh->selectrow_array(qq[SELECT sum(t_amnt) FROM transactions WHERE t_aid1 = ? AND t_id IN ($str) AND t_currency=? ],undef,$aid,$_);
	my $s2=$dbh->selectrow_array(qq[SELECT sum(t_amnt) FROM transactions WHERE t_aid2 = ? AND t_id IN ($str)  AND t_currency=? ],undef,$aid,$_);

	$s2-=$s1;

	my $s3=$dbh->selectrow_array(qq[SELECT sum(t_amnt) FROM transactions WHERE t_aid1 = ? AND t_currency=? ],undef,$aid,$_);
	my $s4=$dbh->selectrow_array(qq[SELECT sum(t_amnt) FROM transactions WHERE t_aid2 = ? AND t_currency=? ],undef,$aid,$_);
	$s4-=$s3;
	print "the sum in reports $s2 and from transes $s4  - $_\n ";


}

my $array=$dbh->selectall_hashref(qq[ SELECT t_id FROM transactions WHERE $aid IN (t_aid1,t_aid2)  AND t_id NOT IN ($str) ],'t_id');

print join(",",keys %$array);
print " in accounts - \n";
print "$str \n";


my $time=$TIMER->stop;

print  "time of working is $time ";

database_disconnect();
