#!/usr/bin/perl
use strict;
use Data::Dumper;
use LWP::UserAgent;
use RHP::Timer;
use lib q[/usr/local/www/lib];
use SiteDB;
my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");

=pod
 SELECT * FROM accounts_reports_table  
 WHERE  ct_aid=2950  
 AND ct_id 
 NOT IN 
 (SELECT dp_tid FROM documents_payments WHERE dp_amnt!=0) 
 AND ct_id  NOT  IN 
 (SELECT dr_close_tid FROM documents_requests WHERE dr_aid=2950 )  AND ct_fid=1386 AND ct_status='processed'
=cut


my $sth=$dbh->prepare(qq[
	SELECT a_id 
	FROM transactions,accounts 
	WHERE 
	1386 IN (t_aid1,t_aid2) 
	AND ((t_aid1=a_id AND t_aid1!=1386) 
	OR (t_aid2=a_id AND t_aid2!=1386)) 
	AND a_acid=16 
	AND DATE(t_ts)=DATE(current_timestamp) GROUP BY a_id	    

	]);

$sth->execute();

$TIMER  = RHP::Timer->new();
$TIMER->start('fizzbin');

while(my $r=$sth->fetchrow_hashref())
{
      my $ref=$dbh->selectall_hashref(qq[SELECT ct_id,ct_comment,ct_aid,ct_amnt,DATE(ts) as ts FROM accounts_reports_table                                                                                                                        
      WHERE  ct_aid=$r->{a_id} AND   DATE(ts)= DATE(current_timestamp)  AND ct_id                                                                                                                                                   
      NOT IN                                                                                                                                                      
      (SELECT dp_tid FROM documents_payments WHERE dp_amnt!=0)                                                                                                    
      AND ct_id  NOT  IN                                                                                                                                          
      (SELECT dr_close_tid FROM documents_requests WHERE dr_aid=$r->{a_id} )  AND ct_fid=1386 AND ct_status='processed'],'ct_id');
      print "$r->{a_id} - ";
      my $i=0;
      my @ar;
      
      foreach(keys %$ref){
	    my $row=$ref->{$_};
	    push @ar,$_; 
        
        
      }
      print " $i \n";




}


exit(0);


