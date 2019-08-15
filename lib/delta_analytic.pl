#!/usr/bin/perl
use strict;
use LWP::UserAgent;
use RHP::Timer;
use lib q[/usr/local/www/lib];
use SiteDB;
use Data::Dumper;
use HTTP::Cookies;
database_connect();

open(FL,">/tmp/delta_log") or die $!; 
my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");

our $TIMER;
my $session='figovina_odna';



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

  my $req2 = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/reportsanalytic.cgi');                                                              
  $req2->content_type('application/x-www-form-urlencoded');                                                                                                 
  $req2->content(qq[do=save_common_report_without&session=$session]);                                          
  my $res2 = $ua->request($req2);                                                                                                                           
                                                                                                                    
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
print FL "time of calculate ".$now_string."  the time $time s";
close(FL);
database_disconnect();
