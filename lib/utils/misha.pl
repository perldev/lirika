#!/usr/bin/perl
use strict;
use LWP::UserAgent;
use RHP::Timer;
use lib q[/usr/local/www/lib];
use SiteDB;
use MIME::Base64;
database_connect('fsb','root','ada');
my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");

our $TIMER;


my $session='hervam20286';

$dbh->do(qq[INSERT INTO  oper_sessions SET 
    os_session='$session',
    os_oid=2,
    os_created=current_timestamp,
    os_expired=date_add(current_timestamp,interval 4 hour),
    os_ip='127.0.0.1'
    ]);

my $id=$dbh->selectrow_array(q[SELECT last_insert_id() ]);

$TIMER  = RHP::Timer->new();

$TIMER->start('fizzbin');


my $rows=$dbh->prepare(q[SELECT ct_id,ct_ts2,lcase(ct_comment) as ct_comment 
                                            FROM cashier_transactions 
                                            WHERE ct_aid='755' AND  ct_status='processed'  AND  ct_amnt>0 
                        and ct_comis_percent=2.2
                                           
                    ]);
$rows->execute();

while(my $r=$rows->fetchrow_hashref())
{
 
  my $req = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/ajax.cgi');
  $req->content_type('application/x-www-form-urlencoded');
  $req->content(qq[do=back_firm_req&id=$r->{ct_id}&ajax=1&session=$session]);
  my $res = $ua->request($req);
  # Check the outcome of the response
  my $new_id;
  if ($res->is_success) {
      print $res->content;
      $new_id=int($res->content);
  }else{
    next ;
  }
    next unless($new_id);
    my $ct_aid=755;
    my $req1 = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/firm_input2.cgi');  
    $req1->content_type('application/x-www-form-urlencoded');
    $req1->content(qq[do=edit&action=apply&ct_ts2=$r->{ct_ts2}&__confirm=1&ct_aid=$ct_aid&id=$new_id&ct_id=$new_id&ajax=1&session=$session&ct_comment=$r->{ct_comment}]);
    $res = $ua->request($req1);
    print "process $new_id \n";
  
}
$rows->finish();
my $time=$TIMER->stop;
$dbh->do(q[DELETE FROM oper_sessions WHERE os_id=?],undef,$id);
# open(FL,">>/tmp/mail_log") or die $!;
print  "time of mail   the time $time s";

database_disconnect();
