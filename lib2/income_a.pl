#!/usr/bin/perl
use strict;
use lib q[./];
use SiteDB;


my $sth=$dbh->prepare(q[SELECT dt_aid,
				dt_fid,
				dt_ofid,
				sum(dt_amnt) as dt_amnt,
				dt_currency,
				dt_date 
				FROM 
				documents_transactions 
				WHERE 1 
				AND dt_status IN ('processed','created') 
				AND dt_aid!=0 
				GROUP BY  dt_aid,dt_fid,dt_ofid,dt_currency,dt_date]);

#my $sth=$dbh->prepare(q[SELECT * FROM accounts WHERE  a_acid=2 AND a_status!='deleted' AND a_incom_id IS NULL]);
$sth->execute();

while(my $r=$sth->fetchrow_hashref())
{
    my $row=$dbh->selectrow_hashref(qq[SELECT dr_id,dr_amnt FROM documents_requests 
    WHERE dr_ofid_from=$r->{dt_ofid} AND dr_aid=$r->{dt_aid} AND dr_fid=$r->{dt_fid}  
    AND dr_status='created' AND dr_date='$r->{dt_date}' AND  dr_currency='$r->{dt_currency}' ]);
    if(!$row->{dr_amnt}&&$r->{dt_aid})
    {
	    $dbh->do(qq[INSERT documents_requests SET dr_comis=1.2,dr_aid=$r->{dt_aid},dr_amnt=$r->{dt_amnt},dr_comment='fix',dr_fid=$r->{dt_fid}
	    ,dr_status='created',dr_currency='UAH',dr_ofid_from=$r->{dt_ofid},dr_oid=2,dr_date='$r->{dt_date}'
	    ]); 
	    my $last_insert=$dbh->selectrow_array(q[ SELECT last_insert_id() ]);
	    $dbh->do(qq[UPDATE documents_transactions SET dt_drid=$last_insert WHERE dt_aid=$r->{dt_aid} AND dt_fid=$r->{dt_fid} AND
		    dt_ofid=$r->{dt_ofid} AND dt_date='$r->{dt_date}' AND 
		    dt_currency='$r->{dt_currency}' AND dt_drid IS  NULL AND dt_status IN ('processed','created','confirmed') ]);
    
    
    }
    if($row->{dr_amnt}==$r->{dt_amnt})
    {
	 my $rw=$dbh->selectrow_hashref(qq[SELECT dt_aid,dt_fid,dt_ofid,sum(dt_amnt) as dt_amnt,                                                                                
	 dt_currency,
	 dt_date                                                                                                                                          
	 FROM                                                                                                                                                         
	 documents_transactions                                                                                                                                       
	 WHERE dt_drid=$row->{dr_id} 
	 AND dt_status IN ('processed','created','confirmed') 
	  GROUP BY  dt_aid,dt_fid,dt_ofid,dt_currency,dt_date]); 
	if($rw->{dt_amnt}==$row->{dt_amnt})
	{
	     $dbh->do(qq[UPDATE documents_transactions SET dt_status='canceled' WHERE dt_aid=$r->{dt_aid} AND dt_fid=$r->{dt_fid} AND                         
	                         dt_ofid=$r->{dt_ofid} AND dt_date='$r->{dt_date}' AND                                                                                    
				 dt_currency='$r->{dt_currency}' AND dt_drid IS  NULL AND dt_status IN ('processed','created','confirmed') ]); 
	
	}else
	{
	     $dbh->do(qq[UPDATE documents_transactions SET dt_status='canceled' WHERE dt_drid=$row->{dr_id}  AND dt_aid=$r->{dt_aid} AND dt_fid=$r->{dt_fid} AND                        
	                                      dt_ofid=$r->{dt_ofid} AND dt_date='$r->{dt_date}' AND                                                                       
					                                       dt_currency='$r->{dt_currency}' AND dt_status IN ('processed','created','confirmed') ]); 
									       
	     $dbh->do(qq[UPDATE documents_transactions SET
	    	    dt_drid=$row->{dr_id}  
		    WHERE  dt_drid IS NULL AND dt_aid=$r->{dt_aid} AND dt_fid=$r->{dt_fid} AND
	            dt_ofid=$r->{dt_ofid} AND dt_date='$r->{dt_date}' AND                                                          
		    dt_currency='$r->{dt_currency}' AND dt_status IN ('processed','created','confirm')]);
																	                                                                                 	
	
	}
	

    
    
        print "$row->{dr_amnt},$r->{dt_amnt},$rw->{dt_amnt} \n";
    
    
    }
    if($row->{dr_amnt}!=$r->{dt_amnt})
    {
                                                                                                                                                         
             my $rw=$dbh->selectrow_hashref(qq[SELECT dt_aid,dt_fid,dt_ofid,sum(dt_amnt) as dt_amnt,                                                             
	              dt_currency,                                                                                                                                        
		               dt_date                                                                                                                                             
			        FROM                                                                                                                                                
			         documents_transactions                                                                                                                              
			          WHERE dt_drid=$row->{dr_id}                                                                                                                         
			           AND dt_status IN ('processed','created','confirmed')                                                                                                
			         GROUP BY  dt_aid,dt_fid,dt_ofid,dt_currency,dt_date]);  
	if($row->{dr_amnt}==$rw->{dt_amnt})
	{
	    $dbh->do(qq[UPDATE documents_transactions SET dt_status='canceled' WHERE dt_aid=$r->{dt_aid} AND dt_fid=$r->{dt_fid} AND                        
	                         dt_ofid=$r->{dt_ofid} AND dt_date='$r->{dt_date}' AND                                                                       
	                          dt_currency='$r->{dt_currency}' AND dt_drid IS  NULL AND dt_status IN ('processed','created','confirmed') ]);
	
	
	}else
	{	
	    $dbh->do(qq[UPDATE documents_requests SET dr_amnt=? WHERE dr_ofid_from=$r->{dt_ofid} 
		AND dr_aid=$r->{dt_aid} AND dr_fid=$r->{dt_fid}                                                                         
	        AND dr_status='created' AND dr_date='$r->{dt_date}' AND  dr_currency='$r->{dt_currency}'   ],undef,$r->{dt_amnt}+$rw->{dt_amnt});	
		
	    $dbh->do(qq[UPDATE documents_transactions SET dt_drid=$row->{dr_id} WHERE dt_aid=$r->{dt_aid} AND dt_fid=$r->{dt_fid} AND                         
	                         dt_ofid=$r->{dt_ofid} AND dt_date='$r->{dt_date}' 
				 AND                                                                       
		                 dt_currency='$r->{dt_currency}'  AND dt_status IN ('processed','created','confirmed')  ]);	
	}
	
    
      print "$row->{dr_amnt},$r->{dt_amnt},$rw->{dt_amnt} ".($r->{dt_amnt}+$rw->{dt_amnt})."\n";    
    }
#     print "$row->{dr_amnt},$r->{dt_amnt} \n";     

    
    
    
    
}
