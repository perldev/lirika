#!/usr/bin/perl
use strict;
use MyConfig;
use lib $MyConfig::path;
use warnings;
use SiteDB;
my $EXP=2.1;


my $aid=shift;
my $all_time=shift;
if($all_time){
    $all_time=1;

}else{
    $all_time=0;

}
my $sth=$dbh->prepare(qq[SELECT t_id,t_aid1,t_aid2,t_amnt_before2,t_amnt_before1,t_amnt,t_ts,t_comment 
                    FROM transactions 
                     WHERE 
                    ( DATE(t_ts)=DATE(current_timestamp) OR $all_time )
                    AND $aid  IN (t_aid1,t_aid2) AND t_currency='UAH' ORDER BY t_id ASC]);
$sth->execute();  

my $row1=$sth->fetchrow_hashref();

my $amnt=0;
unless($row1){
    print "no transactions today ;) \n";
    exit(0);

}else{
    
    $amnt=$row1->{t_amnt_before2}+$row1->{t_amnt} if($row1->{t_aid2} eq $aid);
    $amnt=$row1->{t_amnt_before1}-$row1->{t_amnt} if($row1->{t_aid1} eq $aid);


}


my $err=0;
while(my $row=$sth->fetchrow_hashref()){
    
    


    if($row->{t_aid2} eq $aid&&($row->{t_amnt_before2}-$amnt)>$EXP){
	print "Error there $row->{t_id} \n" ;
	$err=1;
 
 
    }
    if($row->{t_aid1} eq $aid&&($row->{t_amnt_before1}-$amnt)>$EXP){
	print "Error there $row->{t_id} \n";
	$err=1;
    
    
    }
    
    if($row->{t_aid2} eq $aid){
        
        print " $row->{t_amnt_before2} eq  $amnt,  "; 
	$amnt+=$row->{t_amnt};
        print " $amnt   the sum is $row->{t_amnt}  $row->{t_comment}  \n";
	if($err){
	    $amnt=$row->{t_amnt_before2}+$row->{t_amnt};	
	}
	
    }
    if($row->{t_aid1} eq $aid){
        print " $row->{t_amnt_before1} eq $amnt,  "; 
        $amnt-=$row->{t_amnt};
        print " $amnt the sum is $row->{t_amnt}  $row->{t_comment}\n";
	 if($err){                                                                                                                                            
             $amnt=$row->{t_amnt_before1}+$row->{t_amnt};                                                                                                     
         } 
    }
    $err=0;



}


