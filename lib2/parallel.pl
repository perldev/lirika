#!/usr/bin/perl
use strict;
#use LWP::UserAgent;
#use RHP::Timer;


use lib q[/usr/local/www/lib];
use SiteDB;
use SiteCommon;
#open(FL,">>/tmp/mail_log") or die $!; 
#my $ua = LWP::UserAgent->new;
#$ua->agent("MyApp/0.1 ");

my $ref=$dbh->selectall_hashref(q[SELECT of_okpo,of_name,of_id FROM out_firms ],'of_id');


foreach(keys %$ref)
{
    my $str=$ref->{$_}->{of_name};

    
    $str=~/[^\d]+(\d+)[^\d]*$/;
    $str=$1;
    next    unless($str);
    
    $dbh->do(q[UPDATE out_firms SET of_okpo=? WHERE of_id=? ],undef,$str,$_);
    print "$ref->{$_}->{of_name} -  $str \n";

}




=pod
my $session='hervam20286';

$dbh->do(qq[INSERT INTO  oper_sessions SET 
	os_session='$session',
	os_oid=2,
	os_created=current_timestamp,
	os_expired=date_add(current_timestamp,interval 4 hour),
	os_ip='127.0.0.1'
	]);
my $id=$dbh->selectrow_array(q[SELECT last_insert_id() ]);
=cut



=pod
##parallel work for owners
 my %ids=(
  668=>33,
  669=>34,
  670=>35,
 );
 my $office=30;
 my $new_office=681;
 my $last_ts;
 foreach(keys %ids)
 {
  
 $last_ts=$dbh->selectrow_array(
 qq[ SELECT max(ts) FROM accounts_reports_table WHERE ct_aid=$_ AND ct_status!='deleted' ]);
 
   $dbh->do(qq[INSERT INTO accounts_reports_table
  (ct_id,ct_aid,ct_comment,ct_oid,o_login,ct_fid,f_name,ct_amnt,
  ct_currency,comission,result_amnt,ct_comis_percent,ct_ext_commission,
  ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,
  ts,col_status,col_ts,ct_status,col_color) 
  SELECT  ct_id,$_ ,
  ct_comment,ct_oid,o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
  result_amnt,ct_comis_percent,ct_ext_commission,ct_date,e_currency2,rate,
  ct_eid,ct_ex_comis_type,ts,col_status,col_ts,ct_status,col_color 
  FROM accounts_reports_table 
  WHERE ct_aid=$ids{$_} AND ct_status!='deleted'
  AND ts>'$last_ts' AND ct_fid not IN ($office,$DELTA)
  ]);
  
   my $req = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/plugin.cgi');                                                                         
 $req->content_type('application/x-www-form-urlencoded');                                                                                                   
   $req->content(qq[action=filter&do=accounts_reports_table_update_account&ct_aid=$_&ct_date=all_time&ajax=1&session=$session]);                     
     my $res = $ua->request($req);                                                                                                                              
   # Check the outcome of the response                                                                                                                        
     if ($res->is_success) {                                                                                                                                    
           print  FL $res->status_line;                                                                                                                               
	     }                                                                                                                                                          
	       else {                                                                                                                                                     
         print   FL $res->status_line;                                                                                                                           
       }                        
  
  
 }
  $last_ts=$dbh->selectrow_array(
 qq[ SELECT max(ts) FROM accounts_reports_table WHERE ct_aid=$new_office AND ct_status!='deleted']);
 
 my $str=join(',',values %ids);
 
 $dbh->do(qq[INSERT INTO accounts_reports_table(ct_id,ct_aid,
 ct_comment,ct_oid,o_login,ct_fid,f_name,ct_amnt,
 ct_currency,comission,result_amnt,
 ct_comis_percent,ct_ext_commission,
 ct_date,e_currency2,rate,ct_eid,
 ct_ex_comis_type,ts,col_status,
 col_ts,ct_status,col_color) 
 SELECT  ct_id,$new_office,ct_comment,ct_oid,
 o_login,ct_fid,f_name,ct_amnt,
 ct_currency,comission,result_amnt,
 ct_comis_percent,ct_ext_commission,ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_status,col_ts,ct_status,col_color FROM accounts_reports_table 
 WHERE ct_aid=$office AND   ts>'$last_ts' AND  ct_fid not IN ($str,744) AND ct_status!='deleted']);
  my $req = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/plugin.cgi');
  $req->content_type('application/x-www-form-urlencoded');
  $req->content(qq[action=filter&do=accounts_reports_table_update_account&ct_aid=$new_office&ct_date=all_time&ajax=1&session=$session]);
  my $res = $ua->request($req);
  # Check the outcome of the response
  if ($res->is_success) {
      print FL  $res->status_line;
  }
  else {
      print FL $res->status_line;
  }

  
my $tids=$dbh->selectrow_array(q[SELECT cr_tids FROM reports WHERE cr_status='created' ORDER BY cr_id DESC LIMIT 1]);
$dbh->do(qq[DELETE FROM accounts_reports_table WHERE ct_id IN ($tids) AND ct_ex_comis_type='transaction' AND ct_aid IN (668,669,670)]);
exit(0);



 my $req1 = HTTP::Request->new(POST => 'http://localhost:8080/');#/cgi-bin/reports.cgi');                                                                          
  $req1->content_type('application/x-www-form-urlencoded');                                                                                                   
# $req1->content(qq[do=save_report_without&ajax=1&session=$session]);                     
       my $res1 = $ua->request($req1);                                                                                                                              
         # Check the outcome of the response                                                                                                                        
	   if ($res1->is_success) {                                                                                                                                    
		    $res1->content;
		    #     print   $res1->status_line;                                                                                                                           
		   }                                                                                                                                                          
		     else {                                                                                                                                                     
		           print  $res1->status_line;                                                                                                                            
			     }                                  
 
 
  my $req2 = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/reports.cgi');                                                                          
    $req2->content_type('application/x-www-form-urlencoded');                                                                                                   
      $req2->content(qq[do=save_report&ajax=1&session=$session]);                     
        my $res2 = $ua->request($req2);                                                                                                                              
	  # Check the outcome of the response                                                                                                                        
	    if ($res2->is_success) {                                                                                                                                    
	          print FL  $res2->status_line;                                                                                                                           
		    }                                                                                                                                                          
		      else {                                                                                                                                                     
		            print FL $res2->status_line;                                                                                                                            
			      }                     
 
=cut
 
 
 
 
# $dbh->do(q[DELETE FROM oper_sessions WHERE os_id=?],undef,$id);
  

 
# close(FL);
###ending of that work

