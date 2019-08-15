package Oper::PlugIn;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
sub setup
{
  my $self = shift;
#  die "here";
  
  $self->run_modes(
       'accounts_reports_table_update_account' => 'accounts_reports_table_update_account',
       'fuck'=>'fuck',
       'repair'=>'repair'
   
  );
}
sub repair{
    my $self=shift;
                                                                                                                                                               
                                                                                                                                                                 
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
	    my $echo='';								                                                                                                                                                                 
	    while(my $r=$sth->fetchrow_hashref())                                                                                                                        
	    {
		
		                                                                                                                                                          
	      my $ref=$dbh->selectall_hashref(qq[SELECT ct_id,ct_comment,ct_aid,ct_amnt,DATE(ts) as ts FROM accounts_reports_table                                   
		    		        WHERE  ct_aid=$r->{a_id} AND   DATE(ts)= DATE(current_timestamp)  AND ct_id                                                                            
						      NOT IN                                                                                                                                                 
				            (SELECT dp_tid FROM documents_payments WHERE dp_amnt!=0)                                                                                               
				          AND ct_id  NOT  IN                                                                                                                                     
				        (SELECT dr_close_tid FROM documents_requests WHERE dr_aid=$r->{a_id} )  AND ct_fid=1386 AND ct_status='processed'],'ct_id');                           
					$echo.= "$r->{a_id} - <br/>";                                                                                                                                 
		    		          my $i=0;                                                                                                                                               
				          my @ar;                                                                                                                                                
				        foreach(keys %$ref){
					    $echo.="$ref->{$_}->{ct_comment} <br/>";
					    #my $id=$self->del_trans($_);
				    	#    push @ar,$_;                                                                                                                                     
					#    push @ar,$id;
					    $i++;
					    
				      }
				      my $str=join(',',@ar);
#			     $dbh->do(qq[UPDATE accounts_reports_table SEt ct_status='deleted' WHERE ct_id IN ($str) AND ct_ex_comis_type='transaction']) if ($str); 
				    $echo.="conclude $i <br/>";
				                                                                                                                                                         
			        
		    }                                   

return $echo;		    
}
sub fuck{
    my $self=shift;
    die "fuck";
    
    

}
sub  accounts_reports_table_update_account1
{
 my $self=shift;
 my $fid=$self->query->param('ct_aid');

  
 
 
 ##this must_be changed
 my $proto={
  'table'=>"accounts_reports_table",  
  'template_prefix'=>"accounts_reports",
  'page_title'=>"  ",
  'sort'=>'ts ASC ',
   
   'fields'=>[
    {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
    {'field'=>"ct_fid", "title"=>"", "category"=>"firms", 'filter'=>"="
      , "type"=>"select"
    },
    	    
    {'field'=>"ct_aid", "title"=>"",'type'=>'select',
 	'titles'=>&get_accounts_simple(),
	'filter'=>'='},
    {'field'=>"ct_amnt", "title"=>"", "no_add_edit"=>1, 'filter'=>"="},
    {'field'=>"ct_currency", "title"=>"", 'filter'=>"="
     , "type"=>"select","titles"=>\@currencies },
    {'field'=>"ct_comment", "title"=>"", "no_add_edit"=>1,},

    {'field'=>"ct_oid", "title"=>"" , "no_add_edit"=>1, "category"=>"operators"},
  ],
};
 
 
###
 


		 $proto->{'extra_where'}=q[ ct_status!='deleted' ];
		$proto->{del_to}=0;
	
	

 	if($fid)	
 	{
 		my $type=$self->query->param('type_time_filter');
 		my $ref=$dbh->selectrow_hashref(q[SELECT * FROM accounts WHERE a_id=?],undef,$fid);	
		map { $proto->{$_}=format_float($ref->{$_}) } keys %$ref;
		$proto->{a_name}=$ref->{a_name};
		my @filter_where;

		unless($USERS_HASH->{$fid})
		{
 			$proto->{beg_uah}=0;#$ref->{a_uah}-$from->{UAH};
  			$proto->{beg_usd}=0;#$ref->{a_usd}-$from->{USD};
  			$proto->{beg_eur}=0;#$ref->{a_eur}-$from->{EUR};
		}else
		{
			$proto->{beg_uah}=0;
			$proto->{beg_usd}=$USERS_HASH->{$fid};
			$proto->{beg_eur}=0;
		}
	
		$proto->{orig__beg_uah}=$proto->{beg_uah};
  		$proto->{orig__beg_usd}=$proto->{beg_usd};
  		$proto->{orig__beg_eur}=$proto->{beg_eur};
	
		$proto->{beg_uah}=format_float($proto->{beg_uah});
  		$proto->{beg_usd}=format_float($proto->{beg_usd});
  		$proto->{beg_eur}=format_float($proto->{beg_eur});

		$proto->{from_date}=format_date($filter_where[0]);
 		$proto->{to_date}=format_date($filter_where[1]);
 		$proto->{reports_rate}=$dbh->selectall_hashref(qq[SELECT 
						rr_rate,rr_date
						FROM reports_rate 
		 				WHERE 
						rr_date>='$filter_where[0]' AND 
						rr_date<='$filter_where[1]'],'rr_date');
 		
 	}	
	   


 	
	$proto->{checked_all}=$dbh->selectrow_array(q[SELECT count(*) FROM accounts_reports_table WHERE ct_status!='deleted' AND ct_aid=?],undef,$fid)==$dbh->selectrow_array(q[SELECT count(*) FROM accounts_reports_table WHERE ct_status!='deleted' AND col_status='yes' AND ct_aid=?],undef,$fid);


	 $proto->{'info'}=get_client_oper_info($fid);

####
   $proto->{'ct_aid'}=$fid;
   $proto->{'sort'}=' ts ASC';
   my %hash;
   $proto->{sums}=\%hash;		
   my $un=$self->proto_list($proto,{fetch_row=>\&sum,after_list=>\&my_last_record}); 
 


}
sub get_right
{
 return 'account';

}
sub my_last_record
{
	my ($rows,$r,$prew,$proto)=@_;

	$proto->{reports_rate}->{$prew} ={rr_rate=>5.05} unless( $proto->{reports_rate}->{ $prew }); 
	$proto->{beg_uah}=$proto->{beg_uah};
  	$proto->{beg_usd}=$proto->{beg_usd};
  	$proto->{beg_eur}=$proto->{beg_eur};	
	unless( defined($prew) )   
	{
			
		$proto->{a_uah}=format_float($proto->{orig__beg_uah});
   		$proto->{a_usd}=format_float($proto->{orig__beg_usd});
 		$proto->{a_eur}=format_float($proto->{orig__beg_eur});
		$proto->{fin_uah}=format_float($proto->{orig__beg_uah});
  		$proto->{fin_usd}=format_float($proto->{orig__beg_usd});
  		$proto->{fin_eur}=format_float($proto->{orig__beg_eur});		
	
	}else
	{

 		push @$rows,{ct_ex_comis_type=>'concl',ct_date=>" :",
  			      	UAH=>	$proto->{sums}->{ $prew }->{'UAH'},
  			      	USD=>	$proto->{sums}->{ $prew }->{'USD'},
 				EUR=>	$proto->{sums}->{ $prew }->{'EUR'},
 				UAH_FORMAT=>format_float($proto->{sums}->{ $prew }->{'UAH'}),
 				USD_FORMAT=>format_float($proto->{sums}->{ $prew }->{'USD'}),
 				EUR_FORMAT=>format_float($proto->{sums}->{ $prew }->{'EUR'}),
 				concl_color=>($proto->{sums}->{ $prew }->{'USD'}+$proto->{sums}->{ $prew }->{'UAH'}/$proto->{reports_rate}->{$prew}->{rr_rate} )>=-0.001
  			     };	
		@$rows=reverse(@$rows); 
		$proto->{a_uah}=format_float($proto->{sums}->{ $prew }->{'UAH'});
   		$proto->{a_usd}=format_float($proto->{sums}->{ $prew }->{'USD'});
 		$proto->{a_eur}=format_float($proto->{sums}->{ $prew }->{'EUR'});
		$proto->{fin_uah}=format_float($proto->{sums}->{ $prew }->{'UAH'});
  		$proto->{fin_usd}=format_float($proto->{sums}->{ $prew }->{'USD'});
  		$proto->{fin_eur}=format_float($proto->{sums}->{ $prew }->{'EUR'});	
	}
    
        if(defined($prew))
        {

                   $dbh->do(q[UPDATE accounts 
			SET a_uah=?,a_usd=?,a_eur=? 
			WHERE a_id=?],undef,$proto->{sums}->{$prew}->{'UAH'},
                               $proto->{sums}->{$prew}->{'USD'},
				$proto->{sums}->{$prew}->{'EUR'},$proto->{'ct_aid'});
        }




}



1;