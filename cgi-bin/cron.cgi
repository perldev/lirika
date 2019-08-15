#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
use strict;

my $lib_path;
BEGIN{
  $lib_path="../lib";    
  $lib_path = $1.$lib_path if($0 =~ /^(.*[\\\/])/);
}
use lib "$lib_path";

use SiteDB;
use SiteCommon;
use CGIBase;

#####################################

print "Content-Type: text/html\n\n";
print "cron is running ...\n";

my $is_debug = 0;

# auto credits ######################


sub process_penalty{
  my ($credit,$amnt,$account_amnt) = @_;

  my $cid = $credit->{c_id};


             my $pass_days = $credit->{pass_days};
             my $day_penalty = ($amnt*$credit->{c_percent})/100;
             my $penalty = 0;

             if($credit->{pass_days} >= $credit->{c_free_days}){               
               $penalty = $day_penalty;
               if($credit->{c_amnt2} == 0){
                 $penalty = $credit->{pass_days} * $day_penalty if($credit->{pass_days});
               }
             }
             
             $dbh->do("UPDATE credits SET c_amnt2=c_amnt2+? WHERE c_id=?"
                 , undef, $penalty, $cid
             ) if($penalty > 0);

  $dbh->do(
    "INSERT INTO credit_logs SET cl_cid=?, cl_ts=NOW(), cl_penalty=?, cl_percent=?, cl_amnt=?"
    , undef, $cid, $penalty, $credit->{c_percent}, $account_amnt
  );

  return $penalty;
}



my @curs = ();
foreach my $row(@currencies){
  push @curs, ($row->{value});
}

   my ($sth, $sql);
   
   my %credit_params={};
   $sth=$dbh->prepare("SELECT * FROM firm_services WHERE fs_id<0");
   $sth->execute();
   while(my $row = $sth->fetchrow_hashref)
   {
     $credit_params{$row->{fs_id}} = $row;
   }
   $sth->finish();


   $sql = qq[SELECT * FROM accounts
     WHERE a_id>0
     ORDER BY a_id
   ];
   $sth=$dbh->prepare($sql);
   $sth->execute();
   while(my $account = $sth->fetchrow_hashref)
   {
     my $aid = $account->{a_id};
     my $aclass = $account->{a_class};
     my $credit_params_field = "fs_".$aclass."_per";

     print "#$aid $account->{a_name}:\n" if($is_debug);

     foreach my $cur(@curs){       
       my $field = "a_".lc($cur);
       my $sum = $account->{$field};
       my $bad_auto_credit = 0;

       #manual credits
       my $sth2=$dbh->prepare(
           "SELECT * 
           , DATEDIFF(now(), c_start) as pass_days
           , date(c_planned_finish) <= date(now()) as is_expired
           FROM credits WHERE c_aid=? AND c_currency=? 
           AND c_planned_finish IS NOT NULL AND c_finish IS NULL" #not completed MANUAL credit
       );
       $sth2->execute($aid, $cur);
       while(my $credit = $sth2->fetchrow_hashref){
         my $cid = $credit->{c_id};
         my $penalty = process_penalty($credit, $credit->{c_amnt}, $sum);

         if($credit->{is_expired}){
             my $csum = $credit->{c_amnt} + $credit->{c_amnt2}; #credit sum with penalty
             $csum += $penalty if($penalty > 0);

             
             my $tid = CGIBase::add_trans(
               {user_id=>1}, #fixme, NEED auto operator id
               {    
                 t_name1 => $aid,
                 t_name2 => $credit_id,
                 t_currency => $cur,
                 t_amnt => $csum,
                 t_comment => "¬озвращение кредита (автоматическое завершение по дате окончани€), $credit->{c_comment}",
               }
             );
             $dbh->do("UPDATE credits SET c_finish=NOW(), c_tid2=? WHERE c_id=?", undef, $tid, $cid);

             $sum -= $csum;
             $bad_auto_credit=1;
         }#if($credit->{is_expired}){
       }
       $sth2->finish();
       

       
       my $credit = $dbh->selectrow_hashref(
           "SELECT * 
           , DATEDIFF(now(), c_start) as pass_days
           FROM credits WHERE c_aid=? AND c_currency=? 
           AND c_planned_finish IS NULL AND c_finish IS NULL" #not completed AUTO credit
           , undef, $aid, $cur
       );

       print "  $sum $cur - credit $credit\n" if($is_debug);

       if($credit){
         my $cid = $credit->{c_id};
         my $csum = $credit->{c_amnt} + $credit->{c_amnt2}; #credit sum with penalty
         if($sum >= $csum){
           my $tid=undef;
           if($csum > 0){             
             $tid = CGIBase::add_trans(
               {user_id=>1}, #fixme, NEED auto operator id
               {    
                 t_name1 => $aid,
                 t_name2 => $credit_id,
                 t_currency => $cur,
                 t_amnt => $csum,
                 t_comment => "ѕен€ автоматического кредита, $credit->{c_comment}",
               }
             );
           }
           $dbh->do("UPDATE credits SET c_finish=NOW(), c_tid2=? WHERE c_id=?", undef, $tid, $cid);
           
         }else{
           if($sum < 0){
             process_penalty($credit, -$sum, $sum);
           }
         }
       }else{#if($credit){
       
	  if($sum < 0){
	
           my $percent = $credit_params{ $bad_auto_credit ? -102 : -101 }->{$credit_params_field};
           my $free_days = $credit_params{-103}->{$credit_params_field};
           my $comment = "јвтоматический кредит на отрицательный баланс";

           my $exist=$dbh->selectrow_array(q[SELECt c_id  FROM credits WHERE c_aid=? 
					    AND  c_planned_finish IS NULL 
					    AND c_oid IS NULL	
					   ],undef,$aid);
	  if($exist)
	  {	
           $dbh->do(
             "INSERT INTO credits
             (c_amnt, c_start, c_aid, c_currency, c_comment, c_percent, c_free_days) 
             VALUES(0, NOW(),?,?,?,?,?);
             "
             , undef, $aid, $cur, $comment, $percent, $free_days
           );
	  }
         }
       }#if($credit){




     }
   }
   $sth->finish();

# end ###############################

print "\ncron end\n";
exit(0);
