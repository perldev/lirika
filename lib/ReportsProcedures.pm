package ReportsProcedures;
use strict;
use SiteDB;	
use SiteConfig;
use Data::Dumper;
use base "Exporter";
use SiteCommon;
use Storable qw( &nfreeze &thaw );
use CGI::Carp qw(fatalsToBrowser);

our @EXPORT = qw(
       get_last_sum_exc
        
       calculate_sum
       get_common_sums
       get_last_sum_exc
       get_last_sum_exc_without
       get_static_cards
       percent_payments
       exclude_system_exchange
       get_permanent_cards
       get_non_identifier

       get_non_identifier_without
       get_permanent_cards_without
       get_firms_balances_without
       get_kcards_without
       
       get_concl_kcards_without
       get_transfer_operations_other_version
       get_last_sum_exc_balance

       get_firms_balances
       get_rates  
       get_kcards
       get_kcards_balance
       get_static_cards
       get_concl_kcards
       restore_state
       save_state
       $non_usual_class
);
my $static_class="'Static'";
##classes used for common or usual  users
our $non_usual_class="'Master','Static'";
my $master_class="'Master'";
sub save_state
{
	my $ref=$dbh->selectall_hashref(q[SELECT a_id,a_usd,a_eur,a_uah,a_class,a_acid FROM accounts],'a_id');
	my $firms=$dbh->selectall_hashref(q[SELECT f_id,f_usd,f_eur,f_uah FROM firms],'f_id');
	$ref->{firms}=$firms;
	my $serialized = nfreeze($ref);    
	return $serialized;
}
sub restore_state
{
	
	my $row=$dbh->selectrow_array(q[SELECT cr_system_state
						        FROM reports_without WHERE cr_status='created'
					        ORDER BY cr_id DESC  LIMIT 1]);

	my %params = %{thaw($row)};

	return \%params;

}
sub get_kcards_without
{
	my $state=shift;
	my @date=shift;    
	my @res;
	##this code must be changend in future
	
	      my ($date1,$date2);             

              if(defined $date[0]) 
              {
                      $date1="t_ts>'$date[0]'"; 
	              }else{
                   $date1=' 1 ';                                                                                                                                
              }                                                                                                                                                    

              if(defined $date[1])                                                                                                                                 
              {                                                                                                                                                    
                  $date2="t_ts<='$date[1]'";                                                                                                             
              }else                                                                                                                                                
              {                                                                                                                                                    
                  $date2=' 1 ';                                                                                                                        
              }       
	
	
	my $ref_master=$dbh->selectall_hashref(q[SELECT a_id,a_name,a_uah,a_usd,a_eur,a_acid,ow_is_system,ow_percent_incom  as percent FROM 
	accounts,owners_without WHERE a_id=ow_aid AND  1],'a_id');
	
	my ($sum_u,$sum_e,$sum_h);

	my %bills=(UAH=>'a_uah',USD=>'a_usd',EUR=>'a_eur');

	my $masters_exclude=$dbh->selectall_hashref(q[SELECT ow_aid FROM owners_without  WHERE ow_is_system='no' ],'ow_aid');
    	my $mst_ex=join(',',keys %$masters_exclude);

   	foreach(  keys %$ref_master)
	{

		        my $sums={};		
		        $sums->{a_name}=$ref_master->{$_}->{a_name};

	        	$sums->{a_id}=$_;
                if($ref_master->{$_}->{a_acid}==$state->{$_}->{a_acid}){
                    
#  		    die $state->{$_}->{a_usd},$ref_master->{$_}->{a_usd},Dumper $ref_master,$state if($_ == 670);
		    $sums->{UAH}=$ref_master->{$_}->{a_uah}-$state->{$_}->{a_uah};
                    $sums->{USD}=$ref_master->{$_}->{a_usd}-$state->{$_}->{a_usd};
                    $sums->{EUR}=$ref_master->{$_}->{a_eur}-$state->{$_}->{a_eur};
		   

		    

=pod
		    if($_==681){

				$sums->{UAH}+=26524137.24;
				$sums->{USD}-=23607365.30;
				$sums->{EUR}-=374245.01;

		    }
		    if($_==670){
				 $sums->{USD}=-19759;
                                 $sums->{UAH}=0;
  					$sums->{EUR}=0;
			
		    
    		    }
  	          if($_==668){
                               $sums->{USD}=-2415;
                               $sums->{UAH}=0;
                               $sums->{EUR}=0;

                               




                    }

			  if($_==669){
                               $sums->{USD}=-4479.88;
                               $sums->{UAH}=0;
                               $sums->{EUR}=0;






                    }

=cut

               



	            my $sth=$dbh->prepare(qq[SELECT *
	                              FROM
	                              exchange_view
	                              WHERE
				                  1
	                              AND $date1
	                              AND $date2 AND 
				                    exchange_view.a_id=$_
                              ]); 
				$sth->execute();
				while(my $r=$sth->fetchrow_hashref())
				{
					 $sums->{ $r->{e_currency1} }+=$r->{e_amnt1};
				     $sums->{ $r->{e_currency2} }-=$r->{e_amnt2};
				}
		        $sth->finish();

                }else{
                        $sums->{UAH}=$ref_master->{$_}->{a_uah};
                        $sums->{USD}=$ref_master->{$_}->{a_usd};
                        $sums->{EUR}=$ref_master->{$_}->{a_eur} 
                        
                        
                }



                 
                 



		$sums->{UAH}=to_prec($sums->{UAH});
		$sums->{USD}=to_prec($sums->{USD}); 
		$sums->{EUR}=to_prec($sums->{EUR});

		$sum_h+=$sums->{UAH};
		$sum_u+=$sums->{USD};
		$sum_e+=$sums->{EUR};
		
		
		
		

		$sums->{ow_is_system}=$ref_master->{$_}->{ow_is_system};
		
		$sums->{before_uah}=$state->{$_}->{a_uah};
		$sums->{before_usd}=$state->{$_}->{a_usd};
		$sums->{before_eur}=$state->{$_}->{a_eur};
  	        push @res,$sums;
	
	}
	
	
	
	unshift @res,{strong=>1,a_id=>0,
	a_name=>'Общие затраты',
	USD=>format_float(to_prec($sum_u)),
	UAH=>format_float(to_prec($sum_h)),
	EUR=>format_float(to_prec($sum_e)),
	uah=>-1*$sum_h,
	usd=>-1*$sum_u,
	eur=>-1*$sum_e};
	return \@res;

#OR (class1='Master' AND t_aid2=$kassa_id)

}
sub get_concl_kcards_without
{
	my ($ref,$delta)=@_;
	my $ref_master=$dbh->selectall_hashref(q[SELECT a_id,a_name,a_uah,a_usd,a_eur,ow_percent_incom,ow_percent_office,ow_is_system FROM 
	accounts_view,owners_without WHERE a_id=ow_aid AND  ow_is_system='no'],'a_id');
	my ($sum,$before);
	my $common={};
	my @of_system;
	
	foreach(@$ref)
	{  
	
		if($_->{ow_is_system} eq 'yes'){
		$common->{usd}+=$_->{USD};
		$common->{eur}+=$_->{EUR};
		$common->{uah}+=$_->{UAH};
		push  @of_system,{a_id=>$_->{a_id},sum=>{usd=>$_->{USD},uah=>$_->{UAH},eur=>$_->{EUR} } };

	     }
	} 
	
	my @res;
	$sum={};
	$before={};
	
	

	foreach(keys %{ $ref_master })	
	{
		
		my @tmp;

		foreach my $key (@$ref)
		{
			
			if($key->{a_id}==$_)
			{
				$sum->{usd}=$key->{USD};
				$before->{usd}=$key->{before_usd};	

				$sum->{uah}=$key->{UAH};
				$before->{uah}=$key->{before_uah};

				$sum->{eur}=$key->{EUR};
				$before->{eur}=$key->{before_eur};
			}
						
				
				
		}

#		die Dumper $ref_master->{$_};
		foreach my $key (@of_system)
		{
			my $tmp={a_id=>$key->{a_id},sum=>{}};
			$tmp->{sum}->{usd}=$key->{sum}->{usd}*$ref_master->{$_}->{ow_percent_office};
			$tmp->{sum}->{eur}=$key->{sum}->{eur}*$ref_master->{$_}->{ow_percent_office};
			$tmp->{sum}->{uah}=$key->{sum}->{uah}*$ref_master->{$_}->{ow_percent_office};	
			push @tmp,$tmp;
				
		}
		
		
		


		$ref_master->{$_}->{ow_system}=\@tmp;

		foreach my $k (keys %{$before})
		{
			$ref_master->{$_}->{$k}={};
			
			$ref_master->{$_}->{$k}->{before}=$before->{$k};
			$ref_master->{$_}->{$k}->{of_non_format}=normal_prec($common->{$k}*$ref_master->{$_}->{ow_percent_office});
			$ref_master->{$_}->{$k}->{of}=format_float($ref_master->{$_}->{$k}->{of_non_format});

			$ref_master->{$_}->{$k}->{per}=$ref_master->{$_}->{ow_percent_incom}*100;

			$ref_master->{$_}->{$k}->{common_non_format}=normal_prec($sum->{$k});
		
			$ref_master->{$_}->{$k}->{common}=format_float($ref_master->{$_}->{$k}->{common_non_format});

			$ref_master->{$_}->{$k}->{earn_non_format}=normal_prec($delta->{$k}*$ref_master->{$_}->{ow_percent_incom});

			$ref_master->{$_}->{$k}->{earn}=format_float($ref_master->{$_}->{$k}->{earn_non_format});
	
			$ref_master->{$_}->{$k}->{concl}=format_float($before->{$k}+$ref_master->{$_}->{$k}->{earn_non_format}+$sum->{$k}+$ref_master->{$_}->{$k}->{of_non_format});
			$ref_master->{$_}->{$k}->{before}=format_float($ref_master->{$_}->{$k}->{before});
			
		}
		
		$sum={usd=>0,eur=>0,uah=>0};
		$before={usd=>0,eur=>0,uah=>0};
		push @res,$ref_master->{$_};

	
		
		
	}
	return  \@res,$common;
}

sub get_kcards
{
	my @date=@_;
	
	my $echs=get_exchanges();
	my ($date1,$date2);
	
	
	if(defined $date[0])
	{
		$date1="ts>'$date[0]'";
	}else
	{
		$date1=' 1 ';
	}
	 	
	if(defined $date[1])
	{
			$date2="ts<='$date[1]'";
	}else
	{
			$date2=' 1 ';
	}

	my @res;
	
	my $ref_master=$dbh->selectall_hashref(q[SELECT a_id,a_name,a_uah,a_usd,a_eur,ow_is_system FROM 
	accounts_view,owners WHERE a_id=ow_aid  AND  1],'a_id');
        my $sum=0;
	my $sums;

	
	foreach(sort keys %$ref_master)
	{
		$sums=calculate_sum(
				{
					a_id=>$_,
					date1=>$date1,
					date2=>$date2,
					date_from=>$date[0],
					date_to=>$date[1]
				}
				);
		$ref_master->{$_}->{before_uah}=$ref_master->{$_}->{a_uah}-$sums->{UAH};
		$ref_master->{$_}->{before_usd}=$ref_master->{$_}->{a_usd}-$sums->{USD};
		$ref_master->{$_}->{before_eur}=$ref_master->{$_}->{a_eur}-$sums->{EUR};
		$ref_master->{$_}->{before_common}=$ref_master->{$_}->{before_eur}*$echs->{EUR}+
		$ref_master->{$_}->{before_usd}*$echs->{USD}+$ref_master->{$_}->{before_uah}*$echs->{UAH};
	
		$ref_master->{$_}->{sum}=to_prec(
							$sums->{UAH}*$echs->{UAH}+
							$sums->{EUR}*$echs->{EUR}+
							$sums->{USD}*1
						)*(-1);
				
		$sum+=$ref_master->{$_}->{sum};
		$ref_master->{$_}->{non_sum}=$ref_master->{$_}->{sum};
		$ref_master->{$_}->{sum}=$ref_master->{$_}->{sum};
		push @res,$ref_master->{$_};
	
	}
	unshift @res,{strong=>1,a_id=>0,a_name=>'Общие затраты',sum=>to_prec($sum)};
	
	return \@res;
}
sub get_rates
{
    my $ts=shift;
    unless($ts){
        $ts='1';
    }else{
        $ts=qq[ DATE(hr_date)='$ts' ];
    }

    my $ref=$dbh->selectrow_hashref(qq[SELECT hr_domi,hr_rate_street,hr_rate_cross 
    FROM header_rates WHERE $ts ORDER BY 
    hr_date DESC LIMIT 1]);

    if(!($ref->{hr_domi}*1)||!($ref->{hr_rate_cross}*1)){
    
    
        $ts=qq[ DATE(hr_date)<DATE(current_timestamp) ];
        $ref=$dbh->selectrow_hashref(qq[SELECT 
        hr_domi,hr_rate_street,hr_rate_cross 
        FROM 
        header_rates WHERE $ts 
	AND hr_domi>1 
	AND hr_rate_cross>1  
	ORDER BY 
        hr_date DESC LIMIT 1]);

    
    }


    my $uah=$ref->{hr_domi};
    
    $uah=$ref->{hr_rate_street}    unless($uah);
    $uah=~/(\w+\.\w+)/;
    $uah=1/$1;
        

    my $eur=$ref->{hr_rate_cross};
    
    $eur=~/(\w+\.\w+)/;                                                                 

    $eur=$1;   
    
    return {eur=>$eur,uah=>$uah,usd=>1};

    
}
##used only for first time objections has changed

sub exclude_system_exchange
{
            my @date=@_;
            my ($date1,$date2);

            if(defined($date[0]))
            {
                $date1="t_ts>'$date[0]'";
            }else
            {
                $date1=' 1 ';
            }
            
            if(defined($date[1]))
            {
                $date2="t_ts<='$date[1]'";
            }else
            {
                    $date2=' 1 ';
            }

               

                          
     my $sth=$dbh->prepare(qq[SELECT *
                             FROM
                             exchange_view
                             WHERE $date1 AND $date2 AND  e_type='system' AND a_id NOT IN (SELECT ow_aid FROM owners_without) 
			     AND a_id NOT IN (33,34,35)
		             ]);       
	
		     
      my %exchanges=(USD=>0,EUR=>0,UAH=>0);                                                                      

      my ($tmp,$sum);                                                                                                                  
      $sth->execute();
      while(my $r=$sth->fetchrow_hashref())                                                                                            
      {                                                                                                                                
              $exchanges{$r->{e_currency1}}-=$r->{e_amnt1};                                                                            
              $exchanges{$r->{e_currency2}}+=$r->{e_amnt2};                                                                            
      }
	
      
      return \%exchanges;
	                                                                                                                  
    
}
    
##not used now)
sub get_transfer_operations_other_version
{
			my @date=@_;
		        my ($date1,$date2);

			if(defined($date[0]))
			{
				$date1="t_ts>'$date[0]'";
			}else
			{
				$date1=' 1 ';
			}
			
		   	if(defined($date[1]))
			{
				$date2="t_ts<='$date[1]'";
			}else
			{
					$date2=' 1 ';
			}
			    
			    
			my $sth=$dbh->prepare(qq[SELECT * 
			FROM 
			exchange_view,accounts_view   
			WHERE  accounts_view.a_id=exchange_view.a_id 
			AND $date1 
			AND $date2 AND a_class NOT in ('Master')
			]);


   	       $sth->execute();
		my %exchanges;
		my %amnts;
		my %comission;
		my ($tmp,$sum);
		while(my $r=$sth->fetchrow_hashref())
		{
		
			$exchanges{$r->{e_currency1}}-=$r->{e_amnt1};
			$exchanges{$r->{e_currency2}}+=$r->{e_amnt2};

		}
		

		
		
		
		
	

	
	$sth=$dbh->prepare(qq[
			SELECT * 
			FROM cashier_transactions,accounts_view,exchange_view
			WHERE  
			accounts_view.a_id=ct_aid 
			AND  ct_eid=e_id 
			AND $date1 AND $date2  
			AND  ct_tid2_comis IS NULL 
			
			]);

	



	$sth->execute();
	while(my $r=$sth->fetchrow_hashref())
	{
			

		$r->{ct_amnt}=abs($r->{ct_amnt});
		$comission{$r->{ct_currency}}+=1/$r->{e_rate}*($r->{e_rate}*$r->{ct_amnt}-$r->{ct_amnt}*($r->{e_rate}-($r->{ct_comis_percent}*$r->{e_rate})/100));
        
	
	}
			$sth->finish();
			if(defined($date[0]))
			{
				$date1="fe_ts>'$date[0]'";
			}else
			{
				$date1=' 1 ';
			}
			
		   	if(defined($date[1]))
			{
				$date2="fe_ts<='$date[1]'";
			}else
			{
					$date2=' 1 ';
			}


	$sth=$dbh->prepare(qq[
			SELECT * 
			FROM firms_exchange_view
			WHERE  
			1 AND $date1 AND $date2  
			]);
	$sth->execute();
	while(my $r=$sth->fetchrow_hashref())
	{
			

			$exchanges{$r->{currency1}}+=$r->{fe_amnt1};
			$exchanges{$r->{currency2}}-=$r->{fe_amnt2};
        }
	$sth->finish();
	return {exch=>\%exchanges,comission=>\%comission};

}

##	get _trans_info
	


sub get_kcards_balance
{
	my @date=@_;
	
	my $echs=get_exchanges();
	my ($date1,$date2);
	
	
	if(defined $date[0])
	{
		$date1="ts>'$date[0]'";
	}else
	{
		$date1=' 1 ';
	}
	 	
	if(defined $date[1])
	{
			$date2="ts<='$date[1]'";
	}else
	{
			$date2=' 1 ';
	}

	my @res;
	my $ref_master=$dbh->selectall_hashref(q[SELECT a_id,a_name,a_uah,a_usd,a_eur, a_btc FROM 
	accounts_view WHERE a_id IN (33,34,35,30) AND  1],'a_id');
        my $sum=0;
	my $sums;
   ##get static cards
   #     my $count_param="CASE   `from`.t_currency WHEN 'EUR' 
   #    THEN `from`.t_amnt*$echs->{EUR} WHEN 'USD' THEN `from`.t_amnt WHEN 'UAH' THEN             `#from`.t_amnt*$echs->{UAH} END ";
   ##30 for office

	
	foreach(sort keys %$ref_master)
	{
		$sums=calculate_sum_without(
				{
					a_id=>$_,
					date1=>$date1,
					date2=>$date2,
					date_from=>$date[0],
					date_to=>$date[1]
				}
				);
		$ref_master->{$_}->{before_uah}=$ref_master->{$_}->{a_uah}-$sums->{UAH};
		$ref_master->{$_}->{before_usd}=$ref_master->{$_}->{a_usd}-$sums->{USD};
		$ref_master->{$_}->{before_eur}=$ref_master->{$_}->{a_eur}-$sums->{EUR};
		$ref_master->{$_}->{before_common}=$ref_master->{$_}->{before_eur}*$echs->{EUR}+
		$ref_master->{$_}->{before_usd}*$echs->{USD}+$ref_master->{$_}->{before_uah}*$echs->{UAH};
	
		
			

		$ref_master->{$_}->{sum}=to_prec(
							$sums->{UAH}*$echs->{UAH}+
							$sums->{EUR}*$echs->{EUR}+
							$sums->{USD}*1
						)*(-1);
				
		$sum+=$ref_master->{$_}->{sum};
		$ref_master->{$_}->{non_sum}=$ref_master->{$_}->{sum};
		$ref_master->{$_}->{sum}=format_float($ref_master->{$_}->{sum});
		push @res,$ref_master->{$_};
	
	}
	
	unshift @res,{strong=>1,a_id=>0,a_name=>'Общие затраты',sum=>to_prec($sum)};
	
	return \@res;
		
	
	
#OR (class1='Master' AND t_aid2=$kassa_id)

}





sub get_firms_balances_without
{
	my $str=qq[
		SELECT f_id,f_name,f_usd,f_uah,f_eur,
		DATE_FORMAT(max(ct_ts),"\%d.\%m.\%y")	 as last_ts 
		FROM firms 
		LEFT JOIN cashier_transactions 
		ON ct_fid=f_id WHERE f_id>0  GROUP BY f_id 
	];
	my $r=$dbh->selectall_hashref($str,'f_id');
	my @firms1;
	my ($sum_h,$sum_u,$sum_e);
	foreach(keys %$r)
	{
		$sum_h+=$r->{$_}->{f_uah};
		$sum_u+=$r->{$_}->{f_usd};
		$sum_e+=$r->{$_}->{f_eur};

		$r->{$_}->{f_uah}=format_float( to_prec(\$r->{$_}->{f_uah}) );
		$r->{$_}->{f_usd}=format_float( to_prec(\$r->{$_}->{f_usd}) );
		$r->{$_}->{f_eur}=format_float( to_prec(\$r->{$_}->{f_eur}) );

		push @firms1,$r->{$_};
	}
	
	my $size=@firms1;
	my @firms2=splice(@firms1,int($size/2));
	if($size%2)
	{
		$size=$size/2+1;	
	}else
	{
		$size=$size/2;	
	}
	
 	
	my @firms;

	##getting the balances of our kassa
    

	my $kassa=$dbh->selectrow_hashref(q[SELECT sum(a_uah) as a_uah,
                                               sum(a_usd) as a_usd ,
                                               sum(a_eur) as a_eur 
                                               FROM accounts,cash_offices 
                                               WHERE a_id=co_aid]);
	push @firms,{
	right_column=>{f_name=>'касса',last_ts=>'',f_uah=>format_float(-1*$kassa->{a_uah}),
	f_eur=>format_float(-1*$kassa->{a_eur}),
	f_usd=>format_float(-1*$kassa->{a_usd})}};

	$sum_h+=-1*$kassa->{a_uah};
	$sum_u+=-1*$kassa->{a_usd};
	$sum_e+=-1*$kassa->{a_eur};

	
     @firms2 = sort { $a->{f_name} cmp $b->{f_name} } @firms2;
	 @firms1 = sort { $a->{f_name} cmp $b->{f_name} } @firms1;

	for(my $i=0;$i<$size;$i++)
	{
 		push @firms,{left_column=>$firms2[$i],right_column=>$firms1[$i]}
	}
	unshift @firms,{strong=>1,left_column=>{f_name=>'всего'},
			right_column=>{f_usd=>$sum_u,f_uah=>$sum_h,f_eur=>$sum_e}};	
	

 	return \@firms;		

}
sub get_non_identifier_without
{
	my @date=@_;
##get static cards
	my ($date1,$date2);
	if(defined($date[0]))
	{
		$date1="ct_ts>'$date[0]'";
	}else
	{
		$date1=' 1 ';
	}	

	if(defined($date[1]))
	{
		$date2="ct_ts<='$date[1]'";
	}else
	{
		$date2=' 1 ';
	}		
	

	my $r=$dbh->selectall_hashref(qq[SELECT f_name,f_id,
	sum(IF(ct_currency='USD',ct_amnt,0)) as f_usd,
	sum(IF(ct_currency='EUR',ct_amnt,0)) as f_eur,
	sum(IF(ct_currency='UAH',ct_amnt,0)) as f_uah
	FROM 
	cashier_transactions as `from`,firms 
	WHERE 
	$date1 AND $date2 AND f_id=ct_fid AND ct_req='no' AND ct_fid>0 AND ct_status='created'  AND  1 GROUP BY f_id 
	ORDER BY f_name ASC],'f_id');
	

	my @non_ident1;
	my ($sum_u,$sum_e,$sum_h);
	
	
	foreach(sort keys %$r)
	{
		$sum_u+=$r->{$_}->{f_usd};
		$sum_e+=$r->{$_}->{f_eur};
		$sum_h+=$r->{$_}->{f_uah};

		$r->{$_}->{f_usd}=format_float( to_prec(\$r->{$_}->{f_usd}) );
		$r->{$_}->{f_eur}=format_float( to_prec(\$r->{$_}->{f_eur}) );
		$r->{$_}->{f_uah}=format_float( to_prec(\$r->{$_}->{f_uah}) );

		push @non_ident1,$r->{$_};
	}
	
	my $size=@non_ident1;

	my @non_ident2=splice(@non_ident1,int($size/2));
	if($size%2)
	{
		$size=$size/2+1;	
	}else
	{
		$size=$size/2;	
	}
	my @non_ident;

	 @non_ident1 = sort { $a->{f_name} cmp $b->{f_name} } @non_ident1;
	 @non_ident2 = sort { $a->{f_name} cmp $b->{f_name} } @non_ident2;

	

	for(my $i=0;$i<$size;$i++)
	{
 		push @non_ident,{left_column=>$non_ident2[$i],right_column=>$non_ident1[$i]}
	}	
	unshift @non_ident,{strong=>1,left_column=>{f_name=>'Разовые'},right_column=>{f_usd=>$sum_u,f_uah=>$sum_h,f_eur=>$sum_e}};
 	return \@non_ident;		

}


sub get_non_identifier
{
	my @date=@_;
	my $echs=get_exchanges();
##get static cards

 

        my $count_param="CASE   `from`.ct_currency WHEN 'EUR' 
        THEN `from`.ct_amnt*$echs->{EUR} WHEN 'USD' THEN `from`.ct_amnt WHEN 'UAH' THEN             `from`.ct_amnt*$echs->{UAH} END ";
	my ($date1,$date2);
	if(defined($date[0]))
	{
		$date1="ct_ts>'$date[0]'";
	}else
	{
		$date1=' 1 ';
	}	

	if(defined($date[1]))
	{
		$date2="ct_ts<='$date[1]'";
	}else
	{
		$date2=' 1 ';
	}		
	

	my $r=$dbh->selectall_hashref(qq[SELECT f_name,f_id,sum($count_param) as amnt 
	FROM 
	cashier_transactions as `from`,firms 
	WHERE 
	$date1 AND $date2 AND f_id=ct_fid AND ct_req='no' AND ct_fid>0 AND ct_status='created'  AND  1 GROUP BY f_id 
	ORDER BY f_name ASC],'f_id');
	

	my @non_ident1;
	my $sum;
	
	foreach(sort keys %$r)
	{
		$sum+=$r->{$_}->{amnt};
		$r->{$_}->{amnt}=format_float( to_prec(\$r->{$_}->{amnt}) );
		push @non_ident1,$r->{$_};
	}
	
	my $size=@non_ident1;

	my @non_ident2=splice(@non_ident1,int($size/2));
	if($size%2)
	{
		$size=$size/2+1;	
	}else
	{
		$size=$size/2;	
	}
	my @non_ident;

	@non_ident1 = sort { $a->{f_name} cmp $b->{f_name} } @non_ident1;
	@non_ident2 = sort { $a->{f_name} cmp $b->{f_name} } @non_ident2;

	

	for(my $i=0;$i<$size;$i++)
	{
 		push @non_ident,{left_column=>$non_ident2[$i],right_column=>$non_ident1[$i]}
	}	

	unshift @non_ident,{strong=>1,left_column=>{f_name=>'всего'},right_column=>{amnt=>$sum}};

 	return \@non_ident;		

}

sub get_firms_balances
{
	
	my $echs=get_exchanges();
##get static cards
        my $count_param="(f_eur*$echs->{EUR}+f_usd+f_uah*$echs->{UAH})";
	my $str=qq[
		SELECT f_id,f_name,$count_param as amnt,
		DATE_FORMAT(max(ct_ts),"\%d.\%m.\%y")	 as last_ts 
		FROM firms 
		LEFT JOIN cashier_transactions 
		ON ct_fid=f_id WHERE f_id>0  GROUP BY f_id 
	];
	my $r=$dbh->selectall_hashref($str,'f_id');
	my @firms1;
	my $sum;
	foreach(keys %$r)
	{
		$sum+=$r->{$_}->{amnt};
		$r->{$_}->{amnt}=format_float( to_prec(\$r->{$_}->{amnt}) );
		push @firms1,$r->{$_};
	}
	
	my $size=@firms1;
	my @firms2=splice(@firms1,int($size/2));
	if($size%2)
	{
		$size=$size/2+1;	
	}else
	{
		$size=$size/2;	
	}
	
 	
	my @firms;

	##getting the balances of our kassa
	
	


	my $kassa=$dbh->selectrow_hashref(q[SELECT sum(a_uah) as a_uah,
                                               sum(a_usd) as a_usd ,
                                               sum(a_eur) as a_eur 
                                               FROM accounts,cash_offices 
                                               WHERE a_id=co_aid]);


	push @firms,{left_column=>{f_name=>'Касса'},
	right_column=>{last_ts=>'Всего',amnt=>format_float(-1*$kassa->{a_uah})}};
	push @firms,{left_column=>{f_name=>'Всего'},
	right_column=>{last_ts=>'USD',amnt=>format_float(-1*$kassa->{a_usd})}};
	push @firms,{left_column=>{f_name=>'Всего'},
	right_column=>{last_ts=>'EUR',amnt=>format_float(-1*$kassa->{a_eur})}};	
	#converting to the usd))
	my $echs_c= get_exchanges_cash();
	$sum+=(-1*$kassa->{a_uah}*$echs_c->{UAH}+
	       -1*$kassa->{a_eur}*$echs_c->{EUR}+
	       -1*$kassa->{a_usd}
		
	     );
	
	 @firms2 = sort { $a->{f_name} cmp $b->{f_name} } @firms2;
	 @firms1 = sort { $a->{f_name} cmp $b->{f_name} } @firms1;

	for(my $i=0;$i<$size;$i++)
	{
 		push @firms,{left_column=>$firms2[$i],right_column=>$firms1[$i]}
	}
	unshift @firms,{strong=>1,left_column=>{f_name=>'Всего'},
			right_column=>{amnt=>$sum}};	
	

 	return \@firms;		
}
sub percent_payments
{
	my @date=@_;
	my $echs=get_exchanges();
	my $count_param="CASE   c_currency WHEN 'EUR' 
        THEN c_amnt2*$echs->{EUR} WHEN 'USD' THEN c_amnt2 WHEN 'UAH' 
	THEN   c_amnt2*$echs->{UAH} END ";
	
	my ($date1,$date2);
	if(defined($date[0]))
	{
		$date1="`from`.t_ts>'$date[0]'";
	}else
	{
		$date1=' 1 ';
	}	

	if(defined($date[1]))
	{
		$date2="from`.t_ts<='$date[1]'";
	}else
	{
		$date2=' 1 ';
	}	


	my $str=qq[
		SELECT 
		t_aid1,
		a_name1,
		sum($count_param) as credit_sum,
		t_ts as ts
		FROM credits,trans_view as `from`
		WHERE  1
		AND c_tid2 IS NOT NULL
		AND t_id=c_tid2 
		AND 	$date1 AND $date2 
		GROUP BY t_aid1
	];
	my $r=$dbh->selectall_hashref($str,'t_aid1');
		
	my @credits1;
	foreach(keys %$r)
	{
		to_prec(\$r->{$_}->{credit_sum});
		push @credits1,$r->{$_};
	}
	
	
	my $size=@credits1;
	
	my @credits2=splice(@credits1,int($size/2));
	if($size%2)
	{
		$size=$size/2+1;	
	}else
	{
		$size=$size/2;	
	}
 	
	my @credits;
	for(my $i=0;$i<$size;$i++)
	{
 		push @credits,{left_column=>$credits2[$i],right_column=>$credits1[$i]}
	}	

	return \@credits;	
}
sub get_permanent_cards_cats
{
	my ($common_result,$cat_id,$sum1,$sum2)=@_;


	my $r=$dbh->selectall_hashref(qq[SELECT  
	a_name,a_id, 
	a_usd as amnt_usd,
        a_eur as amnt_eur, 
        a_uah as amnt_uah, 
        a_btc as amnt_btc,
	DATE_FORMAT(max(t_ts),"\%d.\%m.\%y") as last_ts,ac_title,ac_id 
	FROM accounts_cats,accounts LEFT JOIN transactions  
	ON (t_aid1=a_id 
	OR t_aid2=a_id),classes  
	WHERE c_name 
	NOT IN  ($non_usual_class) 
	AND c_id=a_class 
	AND a_id>1 AND ac_id=a_acid AND a_status!='deleted' AND ac_id=$cat_id
	GROUP BY a_id ORDER BY a_name ASC],'a_id');

	my @plus_cards;
	
	my @keys = sort { $r->{$a}->{a_name} cmp $r->{$b}->{a_name} } keys %$r;
	my $size__=@keys;
	
	
	foreach(@keys)
	{
                foreach my $c (@CURRENCIES){
                    $$sum1->{$c}+=$r->{$_}->{"amnt_".$c};
                }

		push @{$common_result},$r->{$_};
	}
# 
# 	$r=$dbh->selectall_hashref(qq[SELECT  a_name,a_id,a_usd as amnt_usd,
#         a_eur as amnt_eur, 
#         a_uah as amnt_uah, 
#         a_btc as amnt_btc, DATE_FORMAT(max(t_ts),"\%d.\%m.\%y") as last_ts,ac_title,ac_id  
# 	FROM accounts_cats,accounts LEFT JOIN transactions  ON 
# 	(t_aid1=a_id OR t_aid2=a_id),classes  
# 	WHERE c_name NOT IN  ($non_usual_class) AND 
# 	c_id=a_class AND a_status!='deleted' AND a_id>1 AND ac_id=a_acid AND ac_id=$cat_id
# 	GROUP BY a_id  ORDER BY a_name ASC],'a_id');
# 	my @mines_cards;
# 	
# 	 @keys = sort { $r->{$a}->{a_name} cmp $r->{$b}->{a_name} } keys %$r;
# 	my $size__1=@keys;
# 	foreach(@keys)
# 	{
# 		to_prec(\$r->{$_}->{amnt});
# 
# 		$$sum2+=$r->{$_}->{amnt};
# 
# 		$r->{$_}->{amnt}=format_float(-1*$r->{$_}->{amnt});
# 		
# 		push @mines_cards,$r->{$_};
# 
# 	}
# 
# 	
# 	my $size;
# 	if(@mines_cards>=@plus_cards)
# 	{
# 		$size=@mines_cards;	
# 	}else
# 	{
# 		$size=@plus_cards;
# 	}
# 	for(my $i=0;$i<;$i++)
# 	{
# 		push @{$common_result},{mines_column=>$mines_cards[$i],plus_column=>$plus_cards[$i]}
# 	}	
 	
	


}
sub get_permanent_cards_without_cats
{
	
	
	my ($common_result,$echs,$cat_id,$sum1,$sum2)=@_;

        my $count_param="(a_eur*$echs->{EUR}+a_usd+a_uah*$echs->{UAH})";

	my $r=$dbh->selectall_hashref(qq[SELECT  
	a_name,a_id,a_usd,a_eur,a_uah
	FROM accounts_cats,accounts,classes  
	WHERE c_name 
	NOT IN  ($non_usual_class) 
	AND $count_param>0 
	AND c_id=a_class AND a_acid=ac_id AND a_status not in ('deleted','blocked') AND ac_id=$cat_id
	AND a_id>1
	GROUP BY a_id ORDER BY a_name ASC],'a_id');
	my @plus_cards;
	
	my ($sum1_u,$sum1_e,$sum1_h);
	

	$sum1_u=$sum1->{usd};
	$sum1_e=$sum1->{eur};
	$sum1_h=$sum1->{uah};
	
	
	
	my @keys = sort { $r->{$a}->{a_name} cmp $r->{$b}->{a_name} } keys %$r;
	my $size__=@keys;

	foreach(@keys)
	{
		to_prec(\$r->{$_}->{amnt});
		$sum1_u+=$r->{$_}->{a_usd};
		$sum1_h+=$r->{$_}->{a_uah};
		$sum1_e+=$r->{$_}->{a_eur};
		
		$r->{$_}->{a_usd}=format_float($r->{$_}->{a_usd});
		$r->{$_}->{a_eur}=format_float($r->{$_}->{a_eur});
		$r->{$_}->{a_uah}=format_float($r->{$_}->{a_uah});
		
		push @plus_cards,$r->{$_};
	}

	$r=$dbh->selectall_hashref(qq[SELECT  a_name,a_id,
	a_usd,a_eur,a_uah  FROM 
	accounts_cats,accounts,classes  
	WHERE c_name NOT IN  ($non_usual_class) AND $count_param<=0 AND 
	c_id=a_class 	AND a_id>1 AND a_acid=ac_id AND a_status not in ('deleted','blocked') AND ac_id=$cat_id
	  GROUP BY a_id  ORDER BY a_name ASC],'a_id');
	my @mines_cards;
	@keys = sort { $r->{$a}->{a_name} cmp $r->{$b}->{a_name} } keys %$r;
	my $size__1=@keys;
	my ($sum2_u,$sum2_e,$sum2_h);
	
	$sum2_u=$sum2->{usd};
	$sum2_e=$sum2->{eur};
	$sum2_h=$sum2->{uah};

	foreach(@keys)
	{
		
		to_prec(\$r->{$_}->{amnt});
		$sum2_u+=$r->{$_}->{a_usd};
		$sum2_h+=$r->{$_}->{a_uah};
		$sum2_e+=$r->{$_}->{a_eur};
		
		$r->{$_}->{a_usd}=format_float($r->{$_}->{a_usd});
		$r->{$_}->{a_eur}=format_float($r->{$_}->{a_eur});
		$r->{$_}->{a_uah}=format_float($r->{$_}->{a_uah});
		

		push @mines_cards,$r->{$_};
	}

	
	my $size;
	if(@mines_cards>=@plus_cards)
	{
		$size=@mines_cards;	
	}else
	{
		$size=@plus_cards;
	}
	for(my $i=0;$i<$size;$i++)
	{
		
 		push @{$common_result},{mines_column=>$mines_cards[$i],plus_column=>$plus_cards[$i]}
	}
	$sum1->{usd}=$sum1_u;
	$sum1->{eur}=$sum1_e;
	$sum1->{uah}=$sum1_h;

	$sum2->{usd}=$sum2_u;
	$sum2->{eur}=$sum2_e;
	$sum2->{uah}=$sum2_h;	


}

sub get_permanent_cards_without
{
##get static cards
##get static cards

	my $echs=get_exchanges();
##get static cards
	my $res=get_cats_simple(undef,[$SYSTEM_ACCOUNTS]);
	my @common_result;

	my $sum1={};
	my $sum2={};
	
	my $tmp_sum1={};
	my $tmp_sum2={};

	my $i=0;
	foreach(@$res)
	{
		map {$tmp_sum1->{$_}=$sum1->{$_}} keys %$sum1;
		map {$tmp_sum2->{$_}=$sum2->{$_}} keys %$sum2;
	
		push @common_result,{is_cat_title=>1,cat_name=>$_->{title},sum_plus=>{},sum_mines=>{} };
		$i=@common_result;
		$i--;

	get_permanent_cards_without_cats(\@common_result,$echs,$_->{value},$sum1,$sum2);
	map { $common_result[$i]->{sum_plus}->{$_}=format_float(($sum1->{$_}-$tmp_sum1->{$_})) } keys %$sum1;
	map { $common_result[$i]->{sum_mines}->{$_}=format_float(($sum2->{$_}-$tmp_sum2->{$_})) } keys %$sum2;

	

	}
	map {$sum1->{$_}=-1*$sum1->{$_}} keys %$sum1;

	map {$sum2->{$_}=-1*$sum2->{$_}} keys %$sum2;

	unshift @common_result,{strong=>1,plus_column=>{a_name=>'Всего',a_usd=>$sum1->{usd},a_eur=>$sum1->{eur},a_uah=>$sum1->{uah}},mines_column=>{a_name=>'Всего',a_usd=>$sum2->{usd},a_eur=>$sum2->{eur},a_uah=>$sum2->{uah}}};
	

	return \@common_result;



 	
}


sub get_permanent_cards
{
	my $echs=get_exchanges();
##get static cards
	my $res=get_cats_simple(undef,[$SYSTEM_ACCOUNTS]);
	my @common_result;
	my %sum1=();
	my %tmp_sum1 = ();
	my $i=0;
	foreach(@$res)
	{
		%tmp_sum1=%sum1;
		push @common_result,{is_cat_title=>1,cat_name=>$_->{title} };
		$i=@common_result;
		$i--;
		get_permanent_cards_cats(\@common_result, $_->{value},\%sum1);
		
		
		foreach my $c (@CURRENCIES){
                    $common_result[$i]->{"sum_".$c}=format_float($sum1{$c}-$tmp_sum1{$c});
		
		}
# 		$common_result[$i]->{sum_usd}=format_float($sum2-$tmp_sum2);
#                 $common_result[$i]->{sum_eur}=format_float($sum2-$tmp_sum2);
# 		$common_result[$i]->{sum_btc}=format_float($sum2-$tmp_sum2);


	}
	
 	unshift @common_result,{strong=>1};
     
	return \@common_result;		
}


sub get_static_cards
{
	my $echs=get_exchanges();
##get static cards
        my $count_param="(a_eur*$echs->{EUR}+a_usd+a_uah*$echs->{UAH})";
	my $r=$dbh->selectall_hashref(qq[SELECT  a_name,a_id,$count_param as amnt,DATE_FORMAT((max(t_ts),"\%d.\%m.\%y") as last_ts  FROM accounts LEFT JOIN transactions  ON (t_aid1=a_id OR t_aid2=a_id),classes  WHERE c_name  IN ($static_class) AND c_id=a_class  GROUP BY a_id],'a_id');
	my @static_cards1;
	foreach(keys %$r)
	{
		to_prec(\$r->{$_}->{amnt});
		push @static_cards1,$r->{$_};
	}
	my $size=@static_cards1;
	my @static_cards2=splice(@static_cards1,int($size/2));
	if($size%2)
	{
		$size=$size/2+1;	
	}else
	{
		$size=$size/2;	
	}
	my @static_cards;
	for(my $i=0;$i<$size;$i++)
	{
 		push @static_cards,{left_column=>$static_cards2[$i],right_column=>$static_cards1[$i]}
	}	
	return \@static_cards;	
	

}

sub get_concl_kcards
{
	my ($ref,$delta)=@_;
	my $echs=get_exchanges();
	my $ref_master=$dbh->selectall_hashref(q[SELECT a_id,a_name,a_uah,a_usd,a_eur,ow_percent_incom,ow_percent_office FROM 
	accounts_view,owners WHERE a_id=ow_aid   AND  ow_is_system='no'],'a_id');
	my ($sum,$before);
	my $common=0;
	my @ow_system;
	foreach(@$ref)
	{
		if($_->{ow_is_system} eq 'yes') 
		{
			  $common+=$_->{non_sum};
			  push @ow_system,{a_id=>$_->{a_id},sum=>$_->{non_sum}};

		}

	}


	my @res;
	
	foreach(keys %{ $ref_master })	
	{
		
		##fignya odnako
		foreach my $key (@$ref)
		{
			
			if($key->{a_id}==$_)
			{
				$sum=-1*$key->{non_sum};
				$before=$key->{before_common};	
			}
		}
		my @tmp;
		foreach my $key (@ow_system)
		{
			my $tmp={};
			$tmp->{sum}=-1*$key->{sum}*$ref_master->{$_}->{ow_percent_office};
			$tmp->{a_id}=$key->{a_id};
			push @tmp,$tmp;    
		}
		
		$ref_master->{$_}->{ow_system}=\@tmp;
		$ref_master->{$_}->{before}=$before;
		$ref_master->{$_}->{of_non_format}=(-1)*$common*$ref_master->{$_}->{ow_percent_office};
		$ref_master->{$_}->{of}=format_float($ref_master->{$_}->{of_non_format});
		$ref_master->{$_}->{per}=$ref_master->{$_}->{ow_percent_incom}*100;
		
		$ref_master->{$_}->{common}=$sum;
		$ref_master->{$_}->{earn_non_format}=$delta*$ref_master->{$_}->{ow_percent_incom};
		$ref_master->{$_}->{earn}=format_float($ref_master->{$_}->{earn_non_format});
		$ref_master->{$_}->{concl_non_format}=$before+$ref_master->{$_}->{earn_non_format}+$sum+$ref_master->{$_}->{of_non_format};
		$ref_master->{$_}->{concl}=format_float($ref_master->{$_}->{concl_non_format});
		$ref_master->{$_}->{before}=format_float($before);
		push @res,$ref_master->{$_};
		
	}
	return  \@res;
}




sub get_common_sums
{

	my @date=@_;
	my $echs=get_exchanges();
        my $count_param="(a_eur*$echs->{EUR}+a_usd+a_uah*$echs->{UAH})";
	my $sum=$dbh->selectrow_array(qq[SELECT sum($count_param) FROM accounts_view WHERE a_class NOT IN ($non_usual_class) AND  a_id>0 ]); 

        $count_param="( f_eur*$echs->{EUR}+f_usd+f_uah*$echs->{UAH} )";

	$sum+=$dbh->selectrow_array(qq[SELECT sum($count_param) FROM firms ]); 
	
	
	my $percents;

	my ($date1,$date2);
	if(defined($date[0]))
	{
		$date1="c_finish>'$date[0]'";
	}else
	{
		$date1=' 1 ';
	}	

	if(defined($date[1]))
	{
		$date2="c_finish<='$date[1]'";
	}else
	{
		$date2=' 1 ';
	}	
	$count_param="CASE   c_currency WHEN 'EUR' 
        THEN c_amnt2*$echs->{EUR} WHEN 'USD' THEN c_amnt2 WHEN 'UAH' THEN  c_amnt2*$echs->{UAH} END ";

	$percents=$dbh->selectrow_array(
	qq[
			SELECT sum($count_param) FROM credits WHERE 
			$date1 AND $date2		
			
	]);

	
	return {sum=>to_prec($sum),percents=>to_prec($percents)};
	
	
}
sub get_last_sum_exc_without
{
	my $r=$dbh->selectrow_hashref(q[SELECT cr_xml_detailes FROM reports_without  
					    WHERE cr_status='created'  
			    
					    ORDER BY cr_id DESC LIMIT 1]);
	

	if($r)
	{#	return {last_sum_exc_uah=>-75845146.3,last_sum_exc_eur=>251142.37,last_sum_exc_usd=>99418219.77};
  			my %params =%{thaw($r->{cr_xml_detailes})};
			#use Data::Dumper;
			#die Dumper \%params;
	return {last_sum_exc_usd=>$params{work_money_usd},last_sum_exc_eur=>$params{work_money_eur},last_sum_exc_uah=>$params{work_money_uah}};#$params{work_money};
	}else
	{
		return 0;
	}


}
sub get_last_sum_exc_balance
{
	my $r=$dbh->selectrow_hashref(q[SELECT cr_xml_detailes FROM reports  
					    WHERE cr_status='created'  
					    ORDER BY cr_id ASC LIMIT 1]);
	#my @ts=[undef,undef];
	#$ts[0]=$last_ts->[0]->[0];
	#$ts[1]=$last_ts->[0]->[1];

	if($r)
	{	
  	
		my %params = %{thaw($r->{cr_xml_detailes})};
	
	    	
		return $params{work_money};
		    
	
	
	}else
	{
		return 0;
	}

}
sub get_last_sum_exc
{
	my $r=$dbh->selectrow_hashref(q[SELECT cr_xml_detailes FROM reports  
					    WHERE cr_status='created'  
					    
					    ORDER BY cr_id DESC LIMIT 1]);
	#my @ts=[undef,undef];
	#$ts[0]=$last_ts->[0]->[0];
	#$ts[1]=$last_ts->[0]->[1];

	if($r)
	{	
  		#return 341676.87;
		my %params = %{thaw($r->{cr_xml_detailes})};
	
	    	
		return $params{work_money};
		    
	
	
	}else
	{
		return 0;
	}


}


1;
