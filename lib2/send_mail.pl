#!/usr/bin/perl
use strict;
use LWP::UserAgent;
use RHP::Timer;
use lib q[/usr/local/www/lib];
use SiteDB;

open(FL,">/tmp/mail_log") or die $!; 
my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");

our $TIMER;


my $session='hervam20286';
#$dbh->do(q[optimize table cashier_transactions]);
#$dbh->do(q[optimize table transactions]);      
#$dbh->do(q[optimize table accounts_reports_table]); 


$dbh->do(qq[INSERT INTO  oper_sessions SET 
	os_session='$session',
	os_oid=2,
	os_created=current_timestamp,
	os_expired=date_add(current_timestamp,interval 4 hour),
	os_ip='127.0.0.1'
	]);
my $id=$dbh->selectrow_array(q[SELECT last_insert_id() ]);

my $sth=$dbh->prepare(q[SELECT a_id,a_email,a_report_passwd FROM accounts WHERE a_status='active' AND a_issubs='yes']);
$sth->execute();

$TIMER  = RHP::Timer->new();
$TIMER->start('fizzbin');

while(my $r=$sth->fetchrow_hashref())
{
  next	if(!$r->{a_email}||!$r->{a_report_passwd});
  
  my $req = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/accounts_reports.cgi');
  $req->content_type('application/x-www-form-urlencoded');
  $req->content(qq[action=filter&do=send_balance&ct_aid=$r->{a_id}&ct_date=all_time&ajax=1&session=$session]);

  my $res = $ua->request($req);
  # Check the outcome of the response
  
  if ($res->is_success) {
      print  $res->content;
  }
  else {
      print  $res->status_line;
  }
#  sleep(240);
  
#  close(FL);
#    exit(0);
  


}

#close(FL);
#die "everything  ok !";




   my $req2 = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/reports.cgi');                                                              
  $req2->content_type('application/x-www-form-urlencoded');                                                                                                 
  $req2->content(qq[do=save_report_without&ajax=1&session=$session]);                                          
  my $res2 = $ua->request($req2);                                                                                                                           
     # Check the outcome of the response                                                                                                                       
     if ($res2->is_success) {                                                                                                                                  
            print  FL $res2->content;                                                                                                                                  
     }                                                                                                                                                       
    else {                                                                                                                                                    
         print FL $res2->status_line;                                                                                                                      
    }          


my $time=$TIMER->stop;
$dbh->do(q[DELETE FROM oper_sessions WHERE os_id=?],undef,$id);
my $now_string =  localtime;

# open(FL,">>/tmp/mail_log") or die $!;
print FL "time of mail ".$now_string."  the time $time s";
close(FL);
die "everything  ok !";     