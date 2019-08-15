#!/usr/bin/perl
use strict;
use LWP::UserAgent;
use RHP::Timer;
use lib q[/usr/local/www/lib];
use SiteDB;
my $AID=shift;
my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");


our $TIMER;
my $session='hervam20286';
#$dbh->do(q[optimize table cashier_transactions]);
#$dbh->do(q[optimize table transactions]);      
#$dbh->do(q[optimize table accounts_reports_table]); 


$dbh->do(qq[
	INSERT INTO  oper_sessions SET 
	os_session='$session',
	os_oid=2,
	os_created=current_timestamp,
	os_expired=date_add(current_timestamp,interval 4 hour),
	os_ip='127.0.0.1'
	]);

my $id=$dbh->selectrow_array(q[SELECT last_insert_id() ]);
my $ext='';
if($AID){
    $ext=" a_id=$AID";
}else{
    $ext=' 1 ';
}
    
my $sth=$dbh->prepare(qq[SELECT a_id FROM accounts,usd_cards WHERE a_id=us_aid AND $ext]);

$sth->execute();

$TIMER  = RHP::Timer->new();
$TIMER->start('fizzbin');

while(my $r=$sth->fetchrow_hashref())
{

  my $req = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/acusd.cgi');
  $req->content_type('application/x-www-form-urlencoded');
  $req->content(qq[action=filter&do=list&ct_aid=$r->{a_id}&ct_date=all_time&ajax=1&session=$session]);
 
  my $res = $ua->request($req);
  # Check the outcome of the response
  if ($res->is_success) {
      print   "$r->{a_id}".$res->content." \n";
  }
  else {
      print   $res->status_line;
  }
}

=pod
$TIMER  = RHP::Timer->new();                                                            
$TIMER->start('fizzbin');    

$sth=$dbh->prepare(q[SELECT f_id FROM firms WHERE f_status!='deleted' AND f_id>0]);
$sth->execute();
while(my $r=$sth->fetchrow_hashref())                                                                                                                        
{                                                                                                                                                            
                                                                                                                                                             
  my $req = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/firmsusd.cgi');                                                                           
  $req->content_type('application/x-www-form-urlencoded');                                                                                                   
  $req->content(qq[action=filter&do=list&ct_fid=$r->{f_id}&ct_date=all_time&ajax=1&session=$session]);                                                       
                                                                                                                                                               
    my $res = $ua->request($req);                                                                                                                              
  # Check the outcome of the response                                                                                                                        
    if ($res->is_success) {                                                                                                                                    
      print   "$r->{f_id}".$res->content."\n";                                                                                                                     
    }                                                                                                                                                          
  else {                                                                                                                                                     
    print   $res->status_line;                                                                                                                             
      }                                                                                                                                                          
  }        
=cut





my $time=$TIMER->stop;
$dbh->do(q[DELETE FROM oper_sessions WHERE os_id=?],undef,$id);
my $now_string =  localtime;
exit(0);
# open(FL,">>/tmp/mail_log") or die $!;

