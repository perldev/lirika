#!/usr/bin/perl
use lib q(.);
use SiteConfig;
use SiteDB;
use SiteCommon;
use Data::Dumper;

my $sth=$dbh->prepare(q[SELECT a_id,a_name,a_usd,a_uah,a_eur FROM accounts 
			WHERE 
			a_class!=15  AND a_id=567 AND a_class IN (SELECT c_id FROM classes)]);
$sth->execute();
my $dif={UAH=>0,USD=>0,EUR=>0};



while(my $r=$sth->fetchrow_hashref())
{
 	
		my $proto={};
		unless($USERS_HASH->{$r->{a_id}})
		{
 			$proto->{UAH}=0;#$ref->{a_uah}-$from->{UAH};
  			$proto->{USD}=0;#$ref->{a_usd}-$from->{USD};
  			$proto->{EUR}=0;#$ref->{a_eur}-$from->{EUR};
		}else
		{
			$proto->{UAH}=0;
			$proto->{USD}=$USERS_HASH->{$r->{a_id}};
			$proto->{EUR}=0;
		}
	my $sth1 =$dbh->prepare(
	qq[
		  SELECT 
		  * FROM cashier_transactions LEFT JOIN exchange_view ON e_id=ct_eid
		  WHERE ct_aid=? AND ct_status in ('processed','returned')
		   
	]);
	$sth1->execute($r->{a_id});	
	while(my $r1=$sth1->fetchrow_hashref())
	{
#		print Dumper $r1;		
		if($r1->{ct_eid})
		{    
   	        
#		if($r1->{ct_id} eq 22799)
#		{
#			print Dumper $r1;
#		        print Dumper $proto;
#		}
#		print $proto->{$r1->{ct_currency} }."\n";

		
		my $sum=($r1->{ct_amnt}-$r1->{ct_comis_percent}*($r1->{ct_amnt}/100)-$r1->{ct_ext_commission});
		if($sum<0)
		{    
			$proto->{ $r1->{ct_currency} }+=$sum;
#		print $proto->{$r1->{ct_currency}}."\n";
      	        	$proto->{ $r1->{e_currency2} }-=$sum;                                                                                              
#		print $proto->{$r1->{e_currency2}}."\n";
		
	    		$proto->{ $r1->{e_currency1} }+=$r1->{e_amnt1};        
		}else
		{
		                 $proto->{ $r1->{ct_currency} }+=$sum;                                                                                                        
	 #               print $proto->{$r1->{ct_currency}}."\n";                                                                                                     
		                 $proto->{ $r1->{e_currency1} }-=$sum;                                                                                                        
				 #               print $proto->{$r1->{e_currency2}}."\n";                                                                                                     
	                                                                                                                                                              
		                 $proto->{ $r1->{e_currency2} }+=$r1->{e_amnt2};   
		
		}    
#	        if($r1->{ct_id} eq 22799)
#	        {
#			print Dumper $proto;
#	    	    exit(0);
#	        }
	
		}else
		{    
		
		    $proto->{ $r1->{ct_currency} }+=($r1->{ct_amnt}-$r1->{ct_comis_percent}*(($r1->{ct_amnt})/100)-$r1->{ct_ext_commission});
		     	
		}
	    print  "$r1->{ct_id}  $r1->{ct_amnt} ". Dumper $proto;
		
		
	}
	$sth1->finish();	
	
	
	my $sth2 =$dbh->prepare(
	qq[
		 SELECT 
		  SQL_CALC_FOUND_ROWS * FROM exchange_view
		  WHERE a_id=? AND e_type!='auto'
		
	]);
	$sth2->execute($r->{a_id});
	while(my $r1=$sth2->fetchrow_hashref())
	{
#		print Dumper $r1;
 		$proto->{ $r1->{e_currency1} }-=$r1->{e_amnt1};
		$proto->{ $r1->{e_currency2} }+=$r1->{e_amnt2};
		print "$r1->{e_id} $r->{e_amnt1} ".Dumper $proto;
	}
	$sth2->finish();
	
		
	
	my $sth3 =$dbh->prepare(
	qq[
		SELECT * FROM transfers WHERE t_aid1=?
	]);
	$sth3->execute($r->{a_id});
	while(my $r1=$sth3->fetchrow_hashref())
	{
#		print Dumper $r1;
 		$proto->{ $r1->{t_currency} }-=$r1->{t_amnt};
		print "$r1->{t_id} $r1->{t_amnt} ".Dumper $proto;
	}
	$sth3->finish();
	
	
	
	my $sth4 =$dbh->prepare(
	qq[
		SELECT * FROM transfers WHERE t_aid2=?
	]);
	$sth4->execute($r->{a_id});
	while(my $r1=$sth4->fetchrow_hashref())
	{
#		print Dumper $r1;
 		$proto->{ $r1->{t_currency} }+=$r1->{t_amnt};
		print "$r1->{t_id} $r1->{t_amnt} ".Dumper $proto;
	}
	
	$sth4->finish();




	print "the results of processing $r->{a_id} \n";
	print "result  $r->{a_uah} | $r->{a_usd} | $r->{a_eur} \n";
	print "have $proto->{UAH} | $proto->{USD} | $proto->{EUR} \n";
	print "----------------------------------------\n";
	$dif->{UAH}+=($r->{a_uah}-$proto->{UAH});
	$dif->{USD}+=($r->{a_usd}-$proto->{USD});
	$dif->{EUR}+=($r->{a_eur}-$proto->{EUR});	

 



}
print Dumper $dif;
