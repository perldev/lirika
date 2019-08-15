#!/usr/bin/perl
use strict;
use DBI;
use lib q[./];
#use SiteDB;

  my $dsn = "DBI:mysql:host=localhost;database=fsb";                                                                                                   
  my  $dbh=DBI->connect($dsn, 'root', 'ada', { RaiseError => 1});                                                                                         
      #    $dbh->do("SET charset cp1251;");                                                                                                                        
          $dbh->do("SET names   cp1251;");  


#$dbh->do('LOCK table documents_transactions write,documents_requests write,documents_payments write');

my $sth=$dbh->prepare(q[SELECT  dt_id,
				dt_drid,
				dt_aid,
				dt_fid,
				dt_ofid,
				sum(dt_amnt) as dt_amnt,
				dt_currency,
				CONCAT(MONTH(dt_date),YEAR(dt_date))  as dt_date,
				dt_date as date
				FROM 
				documents_transactions 
				WHERE 1 
				AND dt_status IN ('processed','created') 
				AND dt_aid!=0 
				AND dt_aid IS NOT NULL
				GROUP BY  dt_aid,dt_fid,dt_ofid,dt_currency,dt_date]);

#my $sth=$dbh->prepare(q[SELECT * FROM accounts WHERE  a_acid=2 AND a_status!='deleted' AND a_incom_id IS NULL]);
$sth->execute();

my (%hash,%hash_drids,%hash_tids,%hash_date);

while(my $r=$sth->fetchrow_hashref())
{

    	
	    
    my $row=$dbh->selectrow_hashref(qq[SELECT 
					dr_id,
					dr_aid,
					dr_fid,
					dr_ofid_from,
					dr_amnt,
					CONCAT(MONTH(dr_date),YEAR(dr_date)) as dr_date
					
    FROM documents_requests 
    WHERE dr_id=? ],undef,$r->{dt_drid});
    
    die qq[ fuck off ,$r->{dt_id},$r->{dt_drid} ] unless($row->{dr_id});
    
    if($row->{dr_date} ne $r->{dt_date})
    {
    	    
	    $hash{"$r->{dt_date},$r->{dt_aid},$r->{dt_ofid},$r->{dt_fid},$r->{dt_currency}"}+=$r->{dt_amnt};
            
	    $hash_tids{"$r->{dt_date},$r->{dt_aid},$r->{dt_ofid},$r->{dt_fid},$r->{dt_currency}"}=$hash_tids{"$r->{dt_date},$r->{dt_aid},$r->{dt_ofid},$r->{dt_fid},$r->{dt_currency}"}."$r->{dt_id},";  
	    
	    $hash_date{"$r->{dt_date},$r->{dt_aid},$r->{dt_ofid},$r->{dt_fid},$r->{dt_currency}"}=$r->{date};
	    
	    if($hash_drids{"$r->{dt_date},$r->{dt_aid},$r->{dt_ofid},$r->{dt_fid},$r->{dt_currency}"}&&$hash_drids{"$r->{dt_date},$r->{dt_aid},$r->{dt_ofid},$r->{dt_fid},$r->{dt_currency}"}!=$row->{dr_id})
	    {
		  die qq[ fuck off ,$r->{dt_id},$r->{dt_drid} ];
	    }else{
	    
		$hash_drids{"$r->{dt_date},$r->{dt_aid},$r->{dt_ofid},$r->{dt_fid},$r->{dt_currency}"}=$row->{dr_id}; 
	    
	    }	    
	    #	    $hash{$row->{dr_date}}->{dr_id}=$row->{dr_id};
	    #	    $hash{$row->}
	    
	    print "$row->{dr_id} $row->{dr_amnt},$r->{dt_amnt}  $row->{dr_date} $r->{dt_date}\n";	
	    		
    
    }

    
#     print "$row->{dr_amnt},$r->{dt_amnt} \n";     
}
#$dbh->do(q[ UNLOCK tables ]);      
exit(0);

foreach(keys %hash_drids)
{
    my @ar=split(/,/,$_);
    
#    print qq[UPDATE documents_requests SET dr_amnt=dr_amnt-$hash{$_} WHERE dr_id=$hash_drids{$_} \n];    
#    next;
    $dbh->do(qq[UPDATE documents_requests SET dr_amnt=dr_amnt-$hash{$_} WHERE dr_id=$hash_drids{$_} ]);
    
    $dbh->do(qq[INSERT INTO documents_requests SET 
    dr_comis=1.2,
    dr_aid=$ar[1],
    dr_amnt=$hash{$_},
    dr_comment='fix',
    dr_fid=$ar[3],
    dr_ofid_from=$ar[2],
    dr_oid=2,
    dr_date='$hash_date{$_}'] );
    
    my $id=$dbh->selectrow_array(q[SELECT last_insert_id() ]);
    
    $dbh->do(q[INSERT into documents_payments SET dp_tid=0,dp_ctid=0,dp_drid=?],undef,$id);
    
    chop($hash_tids{$_});
#    die $hash_tids{$_};
    
    $dbh->do(qq[UPDATE documents_transactions SET dt_drid=? WHERE dt_id IN ($hash_tids{$_})],undef,$id);
    print "ok!";
    
    
} 
#$dbh->do(q[ UNLOCK tables ]);




exit(0);
