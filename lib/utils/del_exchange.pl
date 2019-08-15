#!/usr/bin/perl
use strict;
use LWP::UserAgent;
use RHP::Timer;
use MyConfig;

use lib $MyConfig::path;
use SiteDB;
my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");
database_connect();

my $aid=shift;
unless($aid){
    
    print "delete system exchanges from programs \n";
    exit(0);

}

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
print "$aid";
my $id=$dbh->selectrow_array(q[SELECT last_insert_id() ]);

my $e=$dbh->selectall_hashref(qq[SELECT e_id as id FROM exchange_view WHERE e_status!='deleted' AND  a_id=$aid AND e_type!='auto'],'id');


$TIMER  = RHP::Timer->new();
$TIMER->start('fizzbin');

foreach(keys %$e){

     my $req = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/ajax.cgi');
    $req->content_type('application/x-www-form-urlencoded');
    $req->content(qq[do=ajax_exc_back&id=$_&ajax=1&session=$session]);
     my $res = $ua->request($req);
        # Check the outcome of the response
    if ($res->is_success) {
	        print   " $_ ".$res->content." \n";
      }
        else {
          print   $res->status_line;
    }
			          
      

}
my $time=$TIMER->stop;
$dbh->do(q[DELETE FROM oper_sessions WHERE os_id=?],undef,$id);
my $now_string =  localtime;
exit(0);
# open(FL,">>/tmp/mail_log") or die $!;

