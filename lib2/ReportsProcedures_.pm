package ReportsProcedures;
use strict;
use SiteDB;	
use SiteConfig;
use base "Exporter";
use SiteCommon;
use Storable qw( &freeze &thaw );
our @EXPORT = qw(
       get_last_sum_exc
        
       calculate_sum
       get_common_sums
       get_last_sum_exc
	get_last_sum_exc_without
       get_static_cards
       percent_payments

       get_permanent_cards
       get_non_identifier

       get_non_identifier_without
       get_permanent_cards_without
       get_firms_balances_without
       get_kcards_without
       
       get_concl_kcards_without

       get_last_sum_exc_balance

       get_firms_balances
       get_transfer_operations       
       get_kcards
	get_kcards_balance
       get_static_cards
       get_concl_kcards
);
my $static_class="'Static'";
##classes used for common or usual  users
my $non_usual_class="'Master','Static'";
my $master_class="'Master'";

sub get_concl_kcards_without
{
	my ($ref,$delta)=@_;
	my $echs=get_exchanges();
	my $ref_master=$dbh->selectall_hashref(q[SELECT a_id,a_name,a_uah,a_usd,a_eur FROM 
	accounts_view WHERE a_id IN (33,34,35) AND  1],'a_id');
	my ($sum,$before);
	my %hash=(33=>.5,34=>.25,35=>.25);
	my $common;
	map{ $common=$_->{non_sum} if($_->{a_id} == 30) } @$ref;
	my @res;
	foreach(keys %{ $ref_master })	
	{
		
		
		foreach my $key (@$ref)
		{
			
			if($key->{a_id}==$_)
			{
				$sum=-1*$key->{non_sum};
				$before=$key->{before_common};	
			}
						
				
				
		}
				
		$ref_master->{$_}->{before}=$before;

		$ref_master->{$_}->{of}=(-1)*$common*$hash{$_};
		$ref_master->{$_}->{per}=$hash{$_}*100;
		$ref_master->{$_}->{common}=$sum;
		$ref_master->{$_}->{earn}=$delta*$hash{$_};
		$ref_master->{$_}->{concl}=$before+$ref_master->{$_}->{earn}+$sum+$ref_master->{$_}->{of};
		push @res,$ref_master->{$_};
		
	}
	return  \@res;
}

sub get_kcards_without
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
	my $ref_master=$dbh->selectall_hashref(q[SELECT a_id,a_name,a_uah,a_usd,a_eur FROM 
	accounts_view WHERE a_id IN (33,34,35,30) AND  1],'a_id');

        my ($sum_u,$sum_e,$sum_h);

	my $sums;

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
		$sums->{a_name}=$ref_master->{$_}->{a_name};
		$sums->{a_id}=$_;	

		$sum_h+=$sums->{UAH};
		$sum_u+=$sums->{USD};
		$sum_e+=$sums->{EUR};
# 		$ref_master->{$_}->{non_sum}=$ref_master->{$_}->{sum};
# 		$ref_master->{$_}->{sum}=format_float($ref_master->{$_}->{sum});
		push @res,$sums;
	
	}
	unshift @res,{strong=>1,a_id=>0,a_name=>'Общии затраты',USD=>format_float(to_prec($sum_u)),UAH=>format_float(to_prec($sum_h)),EUR=>format_float(to_prec($sum_e))};
	return \@res;
		
	
	
#OR (class1='Master' AND t_aid2=$kassa_id)

}
sub get_transfer_operations
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
			    
			    
			my $sth=$dbh->prepare(qq[SELECT * FROM exchange_view,accounts_view 
					    WHERE 
					    accounts_view.a_id=exchange_view.a_id 
					    AND e_status!='deleted' AND e_type!='auto' 
					    AND $date1 AND $date2 AND a_class 
					    NOT IN ($master_class)]);
					    $sth->execute();
					my %exchanges;
				    my %amnts;
		my ($tmp,$sum);
		while(my $r=$sth->fetchrow_hashref())
		{
			$tmp="$r->{e_currency1}_$r->{e_currency2}";
		
			unless($exchanges{$tmp})
			{
			my @ar;
				$exchanges{$tmp}=\@ar;
				$amnts{$tmp}={};
			}
			push @{$exchanges{$tmp}},{amnt=>$r->{e_amnt1},rate=>$r->{e_rate}};
			$amnts{$tmp}->{amnt}+=$r->{e_amnt1};
			$amnts{$tmp}->{num}+=1;
		}
		map{ $amnts{$_}->{amnt}=$amnts{$_}->{amnt}/$amnts{$_}->{num} }	keys %amnts;

		
		$sth->finish();
		my %exc_info;
		my %avarage_exchanges;
	
	
	foreach my $t ( keys %exchanges)
	{
		    $exc_info{$t}={};
	    	    foreach(@{ $exchanges{$t} })
		    {
				$exc_info{$t}->{rate}+=($_->{amnt}/$amnts{$t}->{amnt})*$_->{rate};
			    	
		    }
		    $exc_info{$t}->{rate}=$exc_info{$t}->{rate}/$amnts{$t}->{num};
		    $exc_info{$t}->{amnt}=$amnts{$t}->{amnt}*$amnts{$t}->{num};
		    
	}


	
	    		my $in=$dbh->selectrow_hashref(qq[SELECT sum(if(t_currency='UAH',t_amnt,0)) as UAH,
						    sum(if(t_currency='USD',t_amnt,0)) as USD,
				    			sum(if(t_currency='EUR',t_amnt,0)) as EUR 
					FROM transactions,accounts_view as a,accounts_view as t
				    	WHERE t_aid2>1 AND t_aid1>1  
					AND  t_aid1=a.a_id AND del_status='processed' 
					AND $date1 AND $date2  AND a.a_class 
				    	IN ($master_class) 
					AND t_aid2=t.a_id AND t.a_class NOT IN ($master_class) 
					]);
				    
			my $out=$dbh->selectrow_hashref(qq[SELECT
			 sum(if(t_currency='UAH',t_amnt,0)) as UAH,
			sum(if(t_currency='USD',t_amnt,0)) as USD,
			sum(if(t_currency='EUR',t_amnt,0)) as EUR 
			FROM transactions,accounts_view as a,accounts_view as t
			WHERE  t_aid1>1 AND t_aid2>1  AND t_aid2=a.a_id 
			AND del_status='processed' AND $date1 AND $date2  AND a.a_class 
				IN ($master_class) AND t_aid1=t.a_id AND t.a_class NOT in
			 ($master_class)]);
			$date1=~s/t_ts/ct_ts2/g;
			$date2=~s/t_ts/ct_ts2/g;
	    		$sth=$dbh->prepare(qq[SELECT * FROM cashier_transactions,accounts_view
			WHERE  accounts_view.a_id=ct_aid 
			AND ct_status 
			IN ('processed','deleted') AND ct_eid IS  
			NULL AND $date1 AND $date2  AND a_class 
		    	NOT IN ($master_class)]);
			$sth->execute();
		    	my %comission;
			while(my $r=$sth->fetchrow_hashref())
	  	  	{
				$comission{$r->{ct_currency}}+=(abs($r->{ct_amnt})/100)*$r->{ct_comis_percent};
	    		}
			$sth->finish();
	
			


		

	   		$sth=$dbh->prepare(qq[SELECT * 
						FROM cashier_transactions,accounts_view,exchange_view
						WHERE  
						accounts_view.a_id=ct_aid 
						AND ct_status IN ('processed','deleted') AND ct_eid=e_id 
						AND $date1 AND $date2  
						AND a_class 
						NOT IN ($master_class)]);
	$sth->execute();
	while(my $r=$sth->fetchrow_hashref())
	{
		$comission{$r->{ct_currency}}+=abs(1/$r->{e_rate}*($r->{e_rate}*$r->{ct_amnt}-$r->{ct_amnt}*($r->{e_rate}+($r->{ct_comis_percent}*$r->{e_rate})/100)));
        }
	$sth->finish();
    
	foreach(keys %exc_info)
	{
		$_=~/([^_]{3})_([^_]{3})/;
		
		$exc_info{$_}->{rate_normal}=pow($exc_info{$_}->{rate},$RATE_FORMS{$1}->{$2});
		$exc_info{$_}->{rate_normal}=POSIX::floor($exc_info{$_}->{rate_normal}*100000)/100000;
		    
			
	}


	

			$date1=~s/ct_ts2/t_date/g;
			$date2=~s/ct_ts2/t_date/g;
			$sth=$dbh->prepare(qq[SELECT t_amnt,t_currency FROM transfers 
			WHERE  t_aid1>1 AND t_aid2=$CORRECT AND $date1 AND $date2  AND 1]);
			$sth->execute();
			while(my $r=$sth->fetchrow_hashref())
	  	  	{
				$comission{$r->{t_currency}}+=$r->{t_amnt};
	    		}
			$sth->finish();
			$sth=$dbh->prepare(qq[SELECT t_amnt,t_currency FROM transfers 
			WHERE  t_aid1=$CORRECT AND t_aid2>1 AND $date1 AND $date2  AND 1]);
			$sth->execute();
			while(my $r=$sth->fetchrow_hashref())
	  	  	{
				$comission{$r->{t_currency}}-=$r->{t_amnt};
	    		}
			$sth->finish();
			
			$sth=$dbh->prepare(qq[SELECT t_amnt,t_currency FROM transfers 
			WHERE  t_aid1>1 AND t_aid2=$credit_id AND $date1 AND $date2  AND 1]);
			$sth->execute();
			while(my $r=$sth->fetchrow_hashref())
	  	  	{
				$comission{$r->{t_currency}}+=$r->{t_amnt};
	    		}
			$sth->finish();
			$sth=$dbh->prepare(qq[SELECT t_amnt,t_currency FROM transfers 
			WHERE  t_aid1=$credit_id AND t_aid2>1 AND $date1 AND $date2  AND 1]);
			$sth->execute();
			while(my $r=$sth->fetchrow_hashref())
	  	  	{
				$comission{$r->{t_currency}}-=$r->{t_amnt};
	    		}
			$sth->finish();


	$comission{'USD'}=format_float(to_prec($comission{'USD'}));
	$comission{'EUR'}=format_float(to_prec($comission{'EUR'}));
	$comission{'UAH'}=format_float(to_prec($comission{'UAH'}));

#	use Data::Dumper;
#	die Dumper {out=>$out,in=>$in,exch=>\%exc_info,comission=>\%comission};
	return {out=>$out,in=>$in,exch=>\%exc_info,comission=>\%comission};

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
	my $ref_master=$dbh->selectall_hashref(q[SELECT a_id,a_name,a_uah,a_usd,a_eur FROM 
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
	
	unshift @res,{strong=>1,a_id=>0,a_name=>'Общии затраты',sum=>to_prec($sum)};
	
	return \@res;
		
	
	
#OR (class1='Master' AND t_aid2=$kassa_id)

}



sub get_permanent_cards_without
{
##get static cards
	my $echs=get_exchanges();
##get static cards
        my $count_param="(a_eur*$echs->{EUR}+a_usd+a_uah*$echs->{UAH})";

	my $r=$dbh->selectall_hashref(qq[SELECT  
	a_name,a_id,a_usd,a_eur,a_uah,
	DATE_FORMAT(max(t_ts),"\%d.\%m.\%y") as last_ts
	FROM accounts LEFT JOIN transactions  
	ON (t_aid1=a_id 
	OR t_aid2=a_id),classes  
	WHERE c_name 
	NOT IN  ($non_usual_class) 
	AND $count_param>0 
	AND c_id=a_class 
	AND a_id>1
	GROUP BY a_id ORDER BY a_name ASC],'a_id');
	my @plus_cards;
	
	my ($sum1_u,$sum1_e,$sum1_h);
	
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
	a_usd,a_eur,a_uah,
	DATE_FORMAT(max(t_ts),"\%d.\%m.\%y") as last_ts  FROM accounts LEFT JOIN transactions  ON 
	(t_aid1=a_id OR t_aid2=a_id),classes  
	WHERE c_name NOT IN  ($non_usual_class) AND $count_param<=0 AND 
	c_id=a_class 	AND a_id>1
	  GROUP BY a_id  ORDER BY a_name ASC],'a_id');
	my @mines_cards;
	@keys = sort { $r->{$a}->{a_name} cmp $r->{$b}->{a_name} } keys %$r;
	my $size__1=@keys;
	my ($sum2_u,$sum2_e,$sum2_h);
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
	my @common_result;
	for(my $i=0;$i<$size;$i++)
	{
		
 		push @common_result,{mines_column=>$mines_cards[$i],plus_column=>$plus_cards[$i]}
	}	
 	unshift @common_result,{strong=>1,plus_column=>{a_name=>'Всего',a_usd=>-1*$sum1_u,a_eur=>-1*$sum1_e,a_uah=>-1*$sum1_h},mines_column=>{a_name=>'Всего',a_usd=>-1*$sum2_u,a_eur=>-1*$sum2_e,a_uah=>-1*$sum2_h}};
	return \@common_result;		
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
	my $kassa=$dbh->selectrow_hashref(q[SELECT * FROM accounts WHERE a_id=?],undef,$kassa_id);
	push @firms,{
	right_column=>{f_name=>'Касса',last_ts=>'',f_uah=>format_float(-1*$kassa->{a_uah}),
	f_eur=>format_float(-1*$kassa->{a_eur}),
	f_usd=>format_float(-1*$kassa->{a_usd})}};

	$sum_h+=-1*$kassa->{a_uah};
	$sum_u+=-1*$kassa->{a_usd};
	$sum_e+=-1*$kassa->{a_eur};

	
	my @firms2 = sort { $a->{f_name} cmp $b->{f_name} } @firms2;
	my @firms1 = sort { $a->{f_name} cmp $b->{f_name} } @firms1;

	for(my $i=0;$i<$size;$i++)
	{
 		push @firms,{left_column=>@firms2[$i],right_column=>@firms1[$i]}
	}
	unshift @firms,{strong=>1,left_column=>{f_name=>'Всего'},
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

	my @non_ident1 = sort { $a->{f_name} cmp $b->{f_name} } @non_ident1;
	my @non_ident2 = sort { $a->{f_name} cmp $b->{f_name} } @non_ident2;

	

	for(my $i=0;$i<$size;$i++)
	{
 		push @non_ident,{left_column=>@non_ident2[$i],right_column=>@non_ident1[$i]}
	}	
	unshift @non_ident,{strong=>1,left_column=>{f_name=>'Всего'},right_column=>{f_usd=>$sum_u,f_uah=>$sum_h,f_eur=>$sum_e}};
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

	my @non_ident1 = sort { $a->{f_name} cmp $b->{f_name} } @non_ident1;
	my @non_ident2 = sort { $a->{f_name} cmp $b->{f_name} } @non_ident2;

	

	for(my $i=0;$i<$size;$i++)
	{
 		push @non_ident,{left_column=>@non_ident2[$i],right_column=>@non_ident1[$i]}
	}	

	unshift @non_ident,{strong=>1,left_column=>{f_name=>'Всего'},right_column=>{amnt=>$sum}};

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
	
	


	my $kassa=$dbh->selectrow_hashref(q[SELECT * FROM accounts WHERE a_id=?],undef,$kassa_id);
	push @firms,{left_column=>{f_name=>'Касса'},
	right_column=>{last_ts=>'ГРН',amnt=>format_float(-1*$kassa->{a_uah})}};
	push @firms,{left_column=>{f_name=>'Касса'},
	right_column=>{last_ts=>'USD',amnt=>format_float(-1*$kassa->{a_usd})}};
	push @firms,{left_column=>{f_name=>'Касса'},
	right_column=>{last_ts=>'EUR',amnt=>format_float(-1*$kassa->{a_eur})}};	
	#converting to the usd))
	my $echs_c= get_exchanges_cash();
	$sum+=(-1*$kassa->{a_uah}*$echs_c->{UAH}+
	       -1*$kassa->{a_eur}*$echs_c->{EUR}+
	       -1*$kassa->{a_usd}
		
	     );
	
	my @firms2 = sort { $a->{f_name} cmp $b->{f_name} } @firms2;
	my @firms1 = sort { $a->{f_name} cmp $b->{f_name} } @firms1;

	for(my $i=0;$i<$size;$i++)
	{
 		push @firms,{left_column=>@firms2[$i],right_column=>@firms1[$i]}
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
 		push @credits,{left_column=>@credits2[$i],right_column=>@credits1[$i]}
	}	

	return \@credits;	
}

sub get_permanent_cards
{
	my $echs=get_exchanges();
##get static cards
        my $count_param="(a_eur*$echs->{EUR}+a_usd+a_uah*$echs->{UAH})";
	my $r=$dbh->selectall_hashref(qq[SELECT  
	a_name,a_id,$count_param as amnt,
	DATE_FORMAT(max(t_ts),"\%d.\%m.\%y") as last_ts
	 FROM accounts LEFT JOIN transactions  
	ON (t_aid1=a_id 
	OR t_aid2=a_id),classes  
	WHERE c_name 
	NOT IN  ($non_usual_class) 
	AND $count_param>0 
	AND c_id=a_class 
	AND a_id>1
	GROUP BY a_id ORDER BY a_name ASC],'a_id');
	my @plus_cards;
	my $sum1;
	my @keys = sort { $r->{$a}->{a_name} cmp $r->{$b}->{a_name} } keys %$r;
	my $size__=@keys;

	foreach(@keys)
	{
		to_prec(\$r->{$_}->{amnt});
		$sum1+=$r->{$_}->{amnt};
		$r->{$_}->{amnt}=format_float($r->{$_}->{amnt});
		
		push @plus_cards,$r->{$_};
	}

	$r=$dbh->selectall_hashref(qq[SELECT  a_name,a_id,$count_param as 
	amnt,DATE_FORMAT(max(t_ts),"\%d.\%m.\%y") as last_ts  FROM accounts LEFT JOIN transactions  ON 
	(t_aid1=a_id OR t_aid2=a_id),classes  
	WHERE c_name NOT IN  ($non_usual_class) AND $count_param<=0 AND 
	c_id=a_class 	AND a_id>1
	  GROUP BY a_id  ORDER BY a_name ASC],'a_id');
	my @mines_cards;
	
	 @keys = sort { $r->{$a}->{a_name} cmp $r->{$b}->{a_name} } keys %$r;
	my $size__1=@keys;
	my $sum2=0;
	foreach(@keys)
	{
		to_prec(\$r->{$_}->{amnt});

		$sum2+=$r->{$_}->{amnt};
		$r->{$_}->{amnt}=format_float(-1*$r->{$_}->{amnt});

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
	my @common_result;
	for(my $i=0;$i<$size;$i++)
	{
		
 		push @common_result,{mines_column=>$mines_cards[$i],plus_column=>$plus_cards[$i]}
	}	
 	unshift @common_result,{strong=>1,plus_column=>{a_name=>'Всего',amnt=>-1*$sum1},
				mines_column=>{a_name=>'Всего',amnt=>-1*$sum2}};

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
	my $ref_master=$dbh->selectall_hashref(q[SELECT a_id,a_name,a_uah,a_usd,a_eur FROM 
	accounts_view WHERE a_id IN (33,34,35) AND  1],'a_id');
	my ($sum,$before);
	my %hash=(33=>.5,34=>.25,35=>.25);
	my $common;
	map{ $common=$_->{non_sum} if($_->{a_id} == 30) } @$ref;
	my @res;
	foreach(keys %{ $ref_master })	
	{
		
		
		foreach my $key (@$ref)
		{
			
			if($key->{a_id}==$_)
			{
				$sum=-1*$key->{non_sum};
				$before=$key->{before_common};	
			}
						
				
				
		}
		$ref_master->{$_}->{before}=$before;
		$ref_master->{$_}->{of}=(-1)*$common*$hash{$_};
		$ref_master->{$_}->{per}=$hash{$_}*100;
		$ref_master->{$_}->{common}=$sum;
		$ref_master->{$_}->{earn}=$delta*$hash{$_};
		$ref_master->{$_}->{concl}=$before+$ref_master->{$_}->{earn}+$sum+$ref_master->{$_}->{of};
		push @res,$ref_master->{$_};
		
	}
	return  \@res;
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
	my $ref_master=$dbh->selectall_hashref(q[SELECT a_id,a_name,a_uah,a_usd,a_eur FROM 
	accounts_view WHERE a_id IN (33,34,35,30) AND  1],'a_id');
        my $sum=0;
	my $sums;
   ##get static cards
   #     my $count_param="CASE   `from`.t_currency WHEN 'EUR' 
   #    THEN `from`.t_amnt*$echs->{EUR} WHEN 'USD' THEN `from`.t_amnt WHEN 'UAH' THEN             `#from`.t_amnt*$echs->{UAH} END ";
   ##30 for office

	
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
		$ref_master->{$_}->{sum}=format_float($ref_master->{$_}->{sum});
		push @res,$ref_master->{$_};
	
	}
	
	unshift @res,{strong=>1,a_id=>0,a_name=>'Общии затраты',sum=>to_prec($sum)};
	
	return \@res;
		
	
	
#OR (class1='Master' AND t_aid2=$kassa_id)

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
	#my @ts=[undef,undef];
	#$ts[0]=$last_ts->[0]->[0];
	#$ts[1]=$last_ts->[0]->[1];

	if($r)
	{	
  			my %params = %{thaw($r->{cr_xml_detailes})};
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
  	
		my %params = %{thaw($r->{cr_xml_detailes})};
	
	    	
		return $params{work_money};
		    
	
	
	}else
	{
		return 0;
	}


}


1;