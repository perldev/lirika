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



my $rows=$dbh->prepare(q[SELECT * FROM accounts_reports_table,transactions WHERE 
                          ct_aid=?  
                          AND ct_id=t_id AND
                          (ct_status!='deleted' OR 1)
                          AND ct_ex_comis_type='transaction'
                    ]);

$rows->execute($aid);
my %set_of=();
my @arr;
while(my $r=$rows->fetchrow_hashref()){
    push @arr,$r->{ct_id};
    $set_of{"transaction$r->{ct_id}"}+=1;

}
$rows->finish();

$rows=$dbh->prepare(q[SELECT * FROM accounts_reports_table,exchange WHERE 
                          ct_id=e_id  
                          AND
                          ct_aid=?  
                          AND
                          (ct_status!='deleted' OR 1)
                          AND ct_ex_comis_type='simple'
                    ]);
$rows->execute($aid);
while(my $r=$rows->fetchrow_hashref()){
    $set_of{"simple$r->{e_id}"}+=1;

    push @arr,$r->{e_tid1};
    push @arr,$r->{e_tid2};
}



$rows->finish();


$rows=$dbh->prepare(q[SELECT ct_tid2,ct_tid2_comis,ct_tid2_ext_com,a.ct_id as id
                          FROM accounts_reports_table as a,cashier_transactions d WHERE 
                          a.ct_id=d.ct_id  
                          AND
                          d.ct_aid=?  
                          AND
                          a.ct_fid>0
                          AND
                          d.ct_eid  IS NULL 
                          AND
                          (a.ct_status!='deleted' OR 1)
                          AND a.ct_ex_comis_type='input'
                    ]);
$rows->execute($aid);
while(my $r=$rows->fetchrow_hashref()){
    $set_of{"input$r->{id}"}+=1;
    push @arr,$r->{ct_tid2};
    push @arr,$r->{ct_tid2_comis} if($r->{ct_tid2_comis});
    push @arr,$r->{ct_tid2_ext_com} if($r->{ct_tid2_ext_com});
}


$rows->finish();


$rows=$dbh->prepare(q[SELECT ct_tid2,ct_tid2_comis,ct_tid2_ext_com,e_tid1,e_tid2,a.ct_id as id
                          FROM accounts_reports_table as a,cashier_transactions d,exchange WHERE 
                          a.ct_id=d.ct_id  
                          AND
                          d.ct_aid=?  
                          AND
                          a.ct_fid>0
                          AND
                          d.ct_eid=e_id
                          AND
                         ( a.ct_status!='deleted' OR 1)
                          AND a.ct_ex_comis_type='input'
                    ]);
$rows->execute($aid);
while(my $r=$rows->fetchrow_hashref()){
    $set_of{"input$r->{id}"}+=1;

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
                                (a.ct_status!='deleted' OR 1)
                                AND a.ct_ex_comis_type='input'
                            ]);
        $rows->execute($aid);
        while(my $r=$rows->fetchrow_hashref()){
            $set_of{"input$r->{id}"}+=1;

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
my %processed=();
my $check=$dbh->selectall_hashref(qq[SELECT  * FROM transactions WHERE $aid in (t_aid1,t_aid2) AND t_id NOT IN ($str) ],'t_id');
my @ee;
foreach my $out (keys %$check){
     my $tmp1=$check->{$out};     
    foreach my $in (keys %$check){
          next  if($in==$out);
          my $tmp2=$check->{$in};
          if($tmp1->{t_amnt}==$tmp2->{t_amnt}&& ( $tmp2->{t_aid2}==$tmp1->{t_aid1} ||$tmp1->{t_aid2}==$tmp2->{t_aid1} ) && $tmp1->{t_currency}==$tmp2->{t_currency}){
   		$processed{$in}=$out;
		$processed{$out}=$in;

          }
    }
}
print "analyze not know transactions \n";
foreach(keys %$check){
    if(!$processed{$_} && $check->{$_}->{t_amnt}!=0){
     print "the trans is not known $_ \n"; 
     push @ee,$_;
   }
    
}
print " concl of doesn't known transes  -" .join(',',sort  @ee)." \n";


my $ref_hash=$dbh->selectall_hashref(qq[SELECT concat(ct_ex_comis_type,ct_id) as id 
                                       FROM accounts_reports_table WHERE ct_aid=$aid AND  ct_status!='deleted' UNION ALL SELECT concat(ct_ex_comis_type,ct_id) as id
                                       FROM accounts_reports_table_archive WHERE ct_aid=$aid AND  ct_status!='deleted'],'id');


my $ref_fact=$dbh->selectall_hashref(qq[SELECT concat('transaction',t_id) as id 
                                       FROM transfers WHERE $aid IN (t_aid1,t_aid2)
                                       UNION ALL
                                       SELECT concat('input',ct_id) as id
                                       FROM cashier_transactions d WHERE 
                                       d.ct_aid=$aid  
                                       AND
                                       d.ct_fid>0
                                       AND
                                       d.ct_eid  IS NULL 
                                       AND
                                       d.ct_status!='deleted'
                                       UNION ALL 
                                       SELECT concat('input',ct_id) as id
                                       FROM cashier_transactions d WHERE 
                                       1
                                       AND
                                       d.ct_aid=$aid  
                                       AND
                                       d.ct_eid IS NOT NULL 
                                       AND
                                       d.ct_fid>0
                                       AND
                                       d.ct_status!='deleted'
                                       UNION ALL
                                       SELECT concat('input',ct_id) as id
                                       FROM cashier_transactions d WHERE 
                                       1  AND
                                       d.ct_aid=$aid  
                                       AND
                                       d.ct_fid<0
                                       AND
                                       d.ct_status NOT IN ('deleted','canceled')
                                       UNION ALL
                                       SELECT CONCAT('simple',e_id) FROM exchange_view WHERE 
                                        1  AND
                                        a_id=$aid 
                                        AND e_type!='auto' aND
                                        e_status!='deleted'
                                        ],'id');


print "analyze accounts reports table and fact \n";

foreach(keys %$ref_hash){
    print "exist in accounts_reports_table '$_' but not in fact \n"    unless($ref_fact->{$_});

}

print "analyze fact tables  \n";
foreach(keys %$ref_fact){
    print "exist in fact tables  '$_' but not in accounts_reports_table \n"    unless($ref_hash->{$_});

}




my $time=$TIMER->stop;

print  "time of working is $time ";

database_disconnect();
