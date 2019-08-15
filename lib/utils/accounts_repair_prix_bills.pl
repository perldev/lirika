#!/usr/bin/perl
use strict;
use Data::Dumper;
use LWP::UserAgent;
use RHP::Timer;
use MyConfig;
use lib $path;
use SiteDB;
my $aid=shift;
database_connect();
my $sth;


$sth=$dbh->prepare(q[SELECT a_id FROM accounts WHERE a_id=?]);
$sth->execute($aid);


$TIMER  = RHP::Timer->new();
$TIMER->start('fizzbin');

while(my $r=$sth->fetchrow_hashref())
{
my $ref;
      my $ref=$dbh->selectall_arrayref(

    qq[SELECT ct_id,ct_comment,ct_aid,ct_amnt,DATE(ts) as ts FROM accounts_reports_table                                                                                                                        
      WHERE  ct_aid=$r->{a_id}  AND ct_id                                                                                                                                                   
      NOT IN                                                                                                                                                      
      (SELECT dp_tid FROM documents_payments WHERE dp_amnt!=0)                                                                                                    
      AND ct_id  NOT  IN                                                                                                                                          
      (SELECT dr_close_tid FROM documents_requests WHERE dr_aid=$r->{a_id} AND dr_status='processed' )   AND ct_status!='deleted']);
      print "$r->{a_id} - ";

      my $i=0;
      my $sum=0;
      my @ar;
      
      foreach(@$ref){
	    my $row=$_;
	    $i++;
	    $sum+=$row->[3];
	    push @ar,$row; 
        
        
      }
      $ref=$dbh->selectall_arrayref(qq[SELECT ct_id,ct_comment,ct_aid,ct_amnt,DATE(ts) as ts FROM accounts_reports_table_archive      
      WHERE  ct_aid=$r->{a_id}  AND ct_id
	NOT IN
      (SELECT dp_tid FROM documents_payments )                                                                               
	AND ct_id  NOT  IN                                                                                                                  
      (SELECT dr_close_tid FROM documents_requests WHERE dr_aid=$r->{a_id} AND dr_close_tid IS NOT NULL)   AND ct_status!='deleted'],undef);

	  foreach(@$ref){
            my $row=$_;
	    $sum+=$row->[3];
		$i++;
            push @ar,$row;

        
      }
      print Dumper \@ar;
     	


      print " $i $sum\n";




}
print "Timer stop - ".$TIMER->stop();
print "\n";


exit(0);


