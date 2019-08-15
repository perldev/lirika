package Oper::AccountsReports;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $users_hash=
{'135'=>7457.59
,
'37'=>-1323948.35
,
'136'=>13435.44
,
'38'=>-12000.00
,
'137'=>-12033.56
,
'138'=>388.75
,
'271'=>-897.61
,
'139'=>51673.20
,
'140'=>-3744.40
,
'272'=>-170.49
,
'141'=>-207.54
,
'142'=>1362888.26
,
'40'=>-17750.00
,
'274'=>45174.33
,
'275'=>-144957.02
,
'276'=>3681.00
,
'143'=>316183.94
,
'144'=>255707.82
,
'145'=>26250.60
,
'41'=>-574.86
,
'278'=>-98648.78
,
'279'=>-58151.00
,
'146'=>-2747.00
,
'147'=>-329925.21
,
'148'=>560.37
,
'280'=>-9950.00
,
'149'=>-6641.00
,
'150'=>3490.00
,
'449'=>-11042.00
,
'43'=>-44.05
,
'283'=>2055.16
,
'26'=>-6946742.42
,
'285'=>-20050.00
,
'286'=>-330404.43
,
'287'=>36198.17
,
'152'=>1761.10
,
'153'=>320097.89
,
'450'=>-15000.00
,
'288'=>-257172.00
,
'289'=>6059.52
,
'291'=>1610.56
,
'46'=>-318047.87
,
'295'=>-81851.28
,
'47'=>-184499.97
,
'296'=>-1798.47
,
'298'=>33618.76
,
'299'=>-50000.00
,
'300'=>-60000.00
,
'48'=>-73986.27
,
'155'=>11860.58
,
'49'=>-12681.96
,
'301'=>-7968.00
,
'50'=>-6933530.02
,
'51'=>-1517862.03
,
'303'=>-853250.00
,
'52'=>36171.17
,
'304'=>-98609.63
,
'156'=>-28572.67
,
'306'=>-45997.00
,
'451'=>-16000.00
,
'157'=>20467.19
,
'54'=>-243337.30
,
'158'=>227199.66
,
'55'=>-14.33
,
'159'=>-30677.00
,
'309'=>13670.00
,
'56'=>597.41
,
'57'=>232.65
,
'129'=>73200.00
,
'160'=>65380.26
,
'58'=>-2490668.25
,
'59'=>-980.00
,
'310'=>-143571.58
,
'311'=>-11753.95
,
'161'=>12017.76
,
'162'=>-42016.21
,
'163'=>-537411.39
,
'312'=>-62465.29
,
'164'=>-28020.62
,
'313'=>-1526.21
,
'61'=>229.69
,
'314'=>196703.22
,
'27'=>6094164.54
,
'62'=>142012.50
,
'166'=>3947.00
,
'315'=>1145.80
,
'167'=>0.00
,
'169'=>-58023.02
,
'170'=>320509.00
,
'171'=>-120207.00
,
'28'=>-774039.27
,
'318'=>49135381.85
,
'319'=>-1454284.60
,
'63'=>-52182.92
,
'320'=>-1865690.00
,
'172'=>30826.90
,
'321'=>-37249.52
,
'322'=>-10527.00
,
'64'=>-1585141.00
,
'323'=>-4875.00
,
'324'=>-282285.00
,
'173'=>-3593274.96
,
'174'=>-13021461.00
,
'325'=>-150000.00
,
'175'=>-985.00
,
'326'=>-2510856.97
,
'327'=>-614941.96
,
'176'=>68284.99
,
'177'=>-117588.00
,
'329'=>18515.99
,
'178'=>-7184.54
,
'179'=>3748.99
,
'180'=>-7000.00
,
'330'=>-14.57
,
'65'=>-272476.94
,
'66'=>807.23
,
'331'=>218.24
,
'181'=>-21491.00
,
'333'=>-155052.00
,
'182'=>32497.81
,
'334'=>55991.50
,
'335'=>-26320.00
,
'452'=>-22129.00
,
'69'=>-11422.11
,
'336'=>11357.39
,
'130'=>-2013.00
,
'337'=>-6893.00
,
'338'=>-13758.00
,
'339'=>-278235.96
,
'184'=>-480000.00
,
'70'=>-560000.00
,
'340'=>-3433194.21
,
'186'=>-1146015.00
,
'341'=>-762147.00
,
'71'=>94540.57
,
'72'=>-49842.40
,
'342'=>2683.82
,
'343'=>-2351.00
,
'73'=>3926.75
,
'344'=>70510.10
,
'74'=>-5081.54
,
'345'=>-50000.00
,
'75'=>-279349.91
,
'187'=>4993.80
,
'188'=>15492.92
,
'346'=>-18704.00
,
'189'=>-466641.73
,
'347'=>-61080.17
,
'191'=>-49890.06
,
'192'=>-215.00
,
'76'=>-3000.00
,
'131'=>-5177.00
,
'29'=>-5246383.03
,
'77'=>-1984825.53
,
'348'=>-216000.00
,
'349'=>-400000.00
,
'193'=>-2600.00
,
'350'=>-1602250.00
,
'351'=>-6951.71
,
'194'=>-80039.74
,
'352'=>-102.91
,
'195'=>-1509035.20
,
'353'=>-1000.00
,
'354'=>89989.71
,
'355'=>-21298.53
,
'196'=>-10000.00
,
'197'=>-3255.31
,
'198'=>204.66
,
'357'=>-1134.80
,
'78'=>936.48
,
'79'=>22014.17
,
'199'=>-13063.08
,
'358'=>390254.98
,
'359'=>-68715.00
,
'360'=>-3353.00
,
'361'=>-154566.00
,
'80'=>-12891.00
,
'362'=>-219.00
,
'453'=>-85426.00
,
'200'=>29557.96
,
'363'=>-4901.98
,
'201'=>-420376.83
,
'83'=>-80000.00
,
'84'=>10143.00
,
'202'=>-152811.68
,
'203'=>-102233.84
,
'364'=>-27648.86
,
'366'=>-4783269.71
,
'204'=>-240000.00
,
'205'=>3064.31
,
'367'=>-544909.73
,
'368'=>-670626.76
,
'206'=>31282.50
,
'207'=>20835.07
,
'85'=>49062.13
,
'369'=>-14681.77
,
'370'=>-50995.00
,
'371'=>49411.51
,
'372'=>117306.88
,
'373'=>131321.27
,
'86'=>-3037.00
,
'87'=>934.76
,
'209'=>-600.00
,
'375'=>6395.63
,
'88'=>356531.51
,
'210'=>-273676.67
,
'211'=>-3001765.00
,
'89'=>-18532.29
,
'376'=>-88661.92
,
'377'=>410.95
,
'212'=>-1000.00
,
'378'=>-155001.00
,
'379'=>-301699.80
,
'90'=>-104515.01
,
'380'=>-1209533.00
,
'91'=>-58383.29
,
'92'=>0.00
,
'381'=>-22942.69
,
'382'=>-26300.99
,
'214'=>-15591.62
,
'383'=>-314801.87
,
'384'=>119855.45
,
'93'=>16265.14
,
'385'=>252.67
,
'30'=>-6139636.88
,
'215'=>-5000.00
,
'94'=>-98862.00
,
'387'=>-9245.80
,
'216'=>-70540.00
,
'95'=>-1466.29
,
'389'=>33646.29
,
'217'=>-21727.00
,
'218'=>579844.55
,
'390'=>-6592.00
,
'219'=>-142628.00
,
'454'=>7917.00
,
'391'=>2050.66
,
'455'=>5044.70
,
'220'=>3953.93
,
'221'=>-6024.70
,
'98'=>-1234673.72
,
'393'=>7014161.44
,
'394'=>-19360.63
,
'222'=>-128157.77
,
'99'=>-12000.00
,
'395'=>38473.76
,
'100'=>-118474.43
,
'223'=>-11962.17
,
'224'=>-4000.00
,
'225'=>-41268.17
,
'226'=>219465.94
,
'397'=>-25019.00
,
'227'=>61140.88
,
'398'=>18.10
,
'101'=>-50000.00
,
'399'=>11342.40
,
'228'=>-186548.91
,
'229'=>-103552.83
,
'230'=>5120.95
,
'231'=>164.18
,
'103'=>-1398.00
,
'403'=>-123538.66
,
'404'=>-54800.07
,
'405'=>1687348.28
,
'104'=>541.87
,
'407'=>7530.71
,
'105'=>-3206.00
,
'232'=>-8000.00
,
'233'=>12800.56
,
'106'=>1624147.05
,
'107'=>21594.00
,
'132'=>20000.00
,
'408'=>5674.31
,
'108'=>-480.00
,
'109'=>3886.68
,
'234'=>2025.46
,
'235'=>-17804.61
,
'409'=>-2153915.09
,
'410'=>-6975921.56
,
'236'=>-30468.00
,
'237'=>-7913.00
,
'238'=>-213.42
,
'411'=>839.57
,
'110'=>57083.03
,
'239'=>-137235.63
,
'240'=>-4200.00
,
'111'=>12264.47
,
'241'=>-78183.87
,
'412'=>26924.02
,
'413'=>-48957.28
,
'414'=>2281.00
,
'415'=>-6000.00
,
'112'=>-34300.07
,
'417'=>-5365.04
,
'242'=>2155.55
,
'243'=>5174.64
,
'244'=>-198.49
,
'115'=>121.64
,
'418'=>20550.75
,
'419'=>-58796.99
,
'245'=>-3697.98
,
'420'=>-10000.00
,
'246'=>2804.24
,
'247'=>9150.00
,
'31'=>23874517.57
,
'32'=>0.00
,
'116'=>289.50
,
'249'=>10986.64
,
'250'=>-13171.33
,
'421'=>34390.13
,
''=>40145.16
,
'422'=>-4897.95
,
'423'=>4665.63
,
'252'=>-41581573.57
,
'424'=>176322.68
,
'253'=>7166.78
,
'254'=>-76686.78
,
'425'=>-99418.00
,
'426'=>-1162.74
,
'427'=>-9846.48
,
'255'=>124.00
,
'428'=>-114889.00
,
'429'=>-380706.00
,
'430'=>-269635.62
,
'119'=>728366.69
,
'120'=>-718993.30
,
'432'=>28998.49
,
'121'=>2572.01
,
'257'=>116604.31
,
'433'=>2873.48
,
'258'=>-2896175.80
,
'259'=>2163520.20
,
'434'=>2100.00
,
'122'=>-2000.00
,
'435'=>-159919.00
,
'260'=>11432.65
,
'436'=>-521835.43
,
'437'=>-36345.00
,
'123'=>-1306044.21
,
'438'=>3181.00
,
'124'=>-106930.26
,
'439'=>-122209.74
,
'440'=>-77372.43
,
'262'=>332717.27
,
'263'=>26122.45
,
'442'=>5379.82
,
'264'=>-1078652.14
,
'134'=>20160.00
,
'126'=>664.48
,
'444'=>-3953.00
,
'445'=>1390.17
,
'127'=>176.50
,
'265'=>78393.07
,
'266'=>-77901.00
,
'128'=>15439.11
,
'446'=>-2535204.07
,
'268'=>47237.65
,
'269'=>-887.00
,
'33'=>38908287.90
,
'34'=>17315268.37
,
'35'=>14900538.35
,
'36'=>38193.14
,
'447'=>-53907.69
,
'448'=>16005.41

};

my $proto={
  'table'=>"accounts_reports",  
  'template_prefix'=>"accounts_reports",
  'page_title'=>"Выписка по клиентам",
  'fields'=>[
    {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
    {'field'=>"ct_fid", "title"=>"Фирма", "category"=>"firms", 'filter'=>"="
      , "type"=>"select"
    },    
    {'field'=>"ct_aid", "title"=>"id Карточки",'filter'=>'='},
    {'field'=>"ct_amnt", "title"=>"Сумма", "no_add_edit"=>1, 'filter'=>"="},
    {'field'=>"ct_currency", "title"=>"Валюта", 'filter'=>"="
     , "type"=>"select","titles"=>\@currencies },
    {'field'=>"ct_comment", "title"=>"Назначение", "no_add_edit"=>1,},
    {'field'=>"ct_oid", "title"=>"Оператор" , "no_add_edit"=>1, "category"=>"operators"},
  ],
};

sub setup
{
  my $self = shift;
  
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',

  );
}
sub get_right
{       
        my $self=shift;
	return 'account';
}
sub list
{
	my $self = shift;
	my $fid=$self->query->param('ct_aid');
 #	if($fid)	
# 	{
 		my $type='all_time';#$self->query->param('type_time_filter');
 		my $ref=$dbh->selectall_arrayref(q[SELECT * FROM accounts WHERE a_id>1]);	
	die "here";	
	foreach(@$ref)	
	{
 	#	map { $proto->{$_}=format_float($ref->{$_}) } keys %$ref;
	#	$proto->{a_name}=$ref->{a_name};
		my @filter_where;
 		
 		if($type  eq 'time_filterinterval')
 		{
 			my $row1={};
 			my $from=$self->query->param('ct_date_from');
 			my $to=$self->query->param('ct_date_to');
 			push @filter_where,$from;
 			push @filter_where,$to;
 		}else
 		{
 			
			my $period=$self->query->param('ct_date');
 			my $res = time_filter($period);
 			push @filter_where,$res->{start};
 			push @filter_where,$res->{end};
 		}				

 		my $from=$dbh->selectrow_hashref(q[
 		SELECT  
 		(
 			SELECT sum(t_amnt) 
 			FROM  transactions 
 			WHERE  t_aid2=?
 			AND t_currency='UAH' 
 			AND t_ts>=? GROUP BY t_aid2
		) AS UAH2,
		(	SELECT sum(t_amnt) 
 			FROM  transactions 
 			WHERE  t_aid1=?
 			AND t_currency='UAH' 
 			AND t_ts>=? GROUP BY t_aid1
		)  as UAH1,
		(
			SELECT sum(t_amnt) 
 			FROM  transactions 
 			WHERE  t_aid2=?
 			AND t_currency='USD' 
 			AND t_ts>=? GROUP BY t_aid2
		) AS USD2,(
			SELECT sum(t_amnt) 
 			FROM  transactions 
 			WHERE  t_aid1=?
 			AND t_currency='USD' 
 			AND t_ts>=? GROUP BY t_aid1
		)   as USD1,
		(
 			SELECT sum(t_amnt) 
 			FROM  transactions 
 			WHERE  t_aid2=?
 			AND t_currency='EUR' 
 			AND t_ts>=? GROUP BY t_aid2
		) as EUR2,(
			SELECT sum(t_amnt) 
 			FROM  transactions 
 			WHERE  t_aid1=?
 			AND t_currency='EUR' 
 			AND t_ts>=? GROUP BY t_aid1
		)   as EUR1
 		],undef,
 		$fid,
  		$filter_where[0],
		$fid,
  		$filter_where[0],
		$fid,
  		$filter_where[0],
		$fid,
  		$filter_where[0],
		$fid,
 		$filter_where[0],
		$fid,
  		$filter_where[0],
		);
		
	

 		
 		my $to=$dbh->selectrow_hashref(q[
 		SELECT  
		(
			SELECT sum(t_amnt) 
			FROM transactions 
			WHERE  t_aid2=? 
			AND t_currency='UAH' 
			AND t_ts>=? AND t_ts<=? GROUP BY t_aid2
		) AS UAH2, 
		(
			SELECT sum(t_amnt) 
			FROM transactions 
			WHERE  t_aid1=? 
			AND t_currency='UAH' 
			AND t_ts>=? AND t_ts<=?  GROUP BY t_aid1
		)
		 as UAH1,
 		( 
			SELECT sum(t_amnt) 
			FROM transactions 
			WHERE  t_aid2=? 
			AND t_currency='USD'  
			AND  t_ts>=? AND t_ts<=? GROUP BY t_aid2) AS USD2,
			( 
				SELECT sum(t_amnt) 
				FROM transactions 
				WHERE  t_aid1=? 
				AND t_currency='USD'  
				AND  t_ts>=? AND t_ts<=? GROUP BY t_aid1
			)  as USD1, 
 			(
  				SELECT sum(t_amnt) 
 				FROM transactions
 				WHERE  t_aid2=?
 				AND t_currency='EUR' 
 				AND t_ts>=? AND t_ts<=?
 				GROUP BY t_aid2
  			) AS EUR2,
			(
				SELECT sum(t_amnt) 
 		   		FROM transactions
	 	   		WHERE  t_aid1=? 
 		   		AND 
 		   		t_currency='EUR' 
 		   		AND t_ts>=? AND t_ts<=?
 		   		GROUP BY t_aid1
			) as EUR1
 		],undef,
 		$fid,
 		$filter_where[0],
 		$filter_where[1],
		$fid,
 		$filter_where[0],
 		$filter_where[1],
 		$fid,
 		$filter_where[0],
 		$filter_where[1],
		$fid,
 		$filter_where[0],
 		$filter_where[1],
 		$fid,
 		$filter_where[0],
 		$filter_where[1],
		$fid,
 		$filter_where[0],
 		$filter_where[1],
 		);
		$from->{UAH}=$from->{UAH2}-$from->{UAH1};
		$from->{EUR}=$from->{EUR2}-$from->{EUR1};
		$from->{USD}=$from->{USD2}-$from->{USD1};

		$to->{UAH}=$to->{UAH2}-$to->{UAH1};
		$to->{USD}=$to->{USD2}-$to->{USD1};
		$to->{EUR}=$to->{EUR2}-$to->{EUR1};
		unless($users_hash->{$fid})
		{
 			$proto->{beg_uah}=0;#$ref->{a_uah}-$from->{UAH};
  			$proto->{beg_usd}=0;#$ref->{a_usd}-$from->{USD};
  			$proto->{beg_eur}=0;#$ref->{a_eur}-$from->{EUR};
		}else
		{
			$proto->{beg_uah}=0;
			$proto->{beg_usd}=$users_hash->{$fid};
			$proto->{beg_eur}=0;
		}

		$proto->{orig__fin_uah}=$proto->{beg_uah}+$to->{UAH};
  		$proto->{orig__fin_usd}=$proto->{beg_usd}+$to->{USD};
  		$proto->{orig__fin_eur}=$proto->{beg_eur}+$to->{EUR};

 		$proto->{fin_uah}=format_float($proto->{orig__fin_uah});
  		$proto->{fin_usd}=format_float($proto->{orig__fin_usd});
  		$proto->{fin_eur}=format_float($proto->{orig__fin_eur});

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
						rr_date>='$filter_where[0]' AND rr_date<='$filter_where[1]'],'rr_date');
 		
 		
   
   $proto->{'ct_aid'}=$fid;
   
   $proto->{'sort'}=' ct_date ASC';
   my %hash;
  
   $proto->{sums}=\%hash;		
   $self->proto_list($proto,{fetch_row=>\&sum,after_list=>\&last_record});
   }


}
sub last_record
{
	my ($rows,$r,$prew)=@_;
 
 	push @$rows,{ct_ex_comis_type=>'concl',ct_date=>"на конец",
  			      	UAH=>	$proto->{sums}->{ $prew }->{'UAH'},
  			      	USD=>	$proto->{sums}->{ $prew }->{'USD'},
 				EUR=>	$proto->{sums}->{ $prew }->{'EUR'},
 				UAH_FORMAT=>format_float($proto->{sums}->{ $prew }->{'UAH'}),
 				USD_FORMAT=>format_float($proto->{sums}->{ $prew }->{'USD'}),
 				EUR_FORMAT=>format_float($proto->{sums}->{ $prew }->{'EUR'}),
 				concl_color=>($proto->{sums}->{ $prew }->{'USD'}>=-0.001&&$proto->{sums}->{ $prew }->{'UAH'}>=-0.001)
  			     };	
	@$rows=reverse(@$rows); 
	$proto->{beg_uah}=$proto->{beg_uah};
  	$proto->{beg_usd}=$proto->{beg_usd};
  	$proto->{beg_eur}=$proto->{beg_eur};
   	$proto->{a_uah}=format_float($proto->{sums}->{ $prew }->{'UAH'});
   	$proto->{a_usd}=format_float($proto->{sums}->{ $prew }->{'USD'});
 	$proto->{a_eur}=format_float($proto->{sums}->{ $prew }->{'EUR'});
	$proto->{fin_uah}=format_float($proto->{sums}->{ $prew }->{'UAH'});
  	$proto->{fin_usd}=format_float($proto->{sums}->{ $prew }->{'USD'});
  	$proto->{fin_eur}=format_float($proto->{sums}->{ $prew }->{'EUR'});
	if(defined($prew))
	{
	
	    $dbh->do(q[UPDATE accounts SET a_uah=?,a_usd=?,a_eur=? WHERE a_id=?],undef,$proto->{sums}->{$prew}->{'UAH'},
	    $proto->{sums}->{$prew}->{'USD'},$proto->{sums}->{$prew}->{'EUR'},$proto->{'ct_aid'});
	
	}



}
sub sum
{
	##$prev_row - in our case its date
	my ($array,$row,$prev_row)=@_;

	
	unless($prev_row)
	{
		##if the first row begin our calculation
		my %hash;
		
		$proto->{sums}->{ $row->{ct_date} }=\%hash;
		$proto->{sums}->{ $row->{ct_date} }->{'UAH'}=$proto->{orig__beg_uah};
		$proto->{sums}->{ $row->{ct_date} }->{'USD'}=$proto->{orig__beg_usd};
		$proto->{sums}->{ $row->{ct_date} }->{'EUR'}=$proto->{orig__beg_eur};

		$proto->{reports_rate}->{ $row->{ct_date} }={rr_rate=>5.05} unless( $proto->{reports_rate}->{ $row->{ct_date} });

		push @$array,{ct_ex_comis_type=>'concl',ct_date=>format_date($row->{ct_date}),
 			      	UAH=>$proto->{sums}->{ $row->{ct_date} }->{'UAH'},
 			      	USD=>$proto->{sums}->{ $row->{ct_date} }->{'USD'},
				EUR=>$proto->{sums}->{ $row->{ct_date} }->{'EUR'},
				UAH_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'UAH'}),
				USD_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'USD'}),
				EUR_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'EUR'}),
 				REPORT_UAH=>
				$proto->{sums}->{ $row->{ct_date} }->{'UAH'}/$proto->{reports_rate}->{ $row->{ct_date} }->{rr_rate},
				concl_color=>($proto->{sums}->{ $row->{ct_date} }->{'UAH'}>=-0.001&&$proto->{sums}->{ $row->{ct_date} }->{'USD'}>=-0.001)
 			     };
		
				
	}
	

	
	unless($proto->{sums}->{$row->{ct_date}})
	{
		##if conclusion calculation for this date
		
		
 	
	
		##
		my %hash;
		$proto->{sums}->{ $row->{ct_date} }=\%hash;
	
		$proto->{sums}->{ $row->{ct_date} }->{UAH}=$proto->{sums}->{ $prev_row }->{UAH};
		$proto->{sums}->{ $row->{ct_date} }->{USD}=$proto->{sums}->{ $prev_row }->{USD};
		$proto->{sums}->{ $row->{ct_date} }->{EUR}=$proto->{sums}->{ $prev_row }->{EUR};
				$proto->{reports_rate}->{ $row->{ct_date} }={rr_rate=>5.05} unless( $proto->{reports_rate}->{ $row->{ct_date} });

		push @$array,{ct_ex_comis_type=>'concl',ct_date=>format_date($row->{ct_date}),
 			      	UAH=>$proto->{sums}->{ $prev_row }->{UAH},
 			      	USD=>$proto->{sums}->{ $prev_row }->{USD},
				EUR=>$proto->{sums}->{ $prev_row }->{EUR},
				UAH_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'UAH'}),
				USD_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'USD'}),
				EUR_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'EUR'}),
				REPORT_UAH=>$proto->{sums}->{ $row->{ct_date} }->{'UAH'}/$proto->{reports_rate}->{ $row->{ct_date} }->{rr_rate},
				concl_color=>($proto->{sums}->{ $row->{ct_date} }->{'UAH'}>=0&&$proto->{sums}->{ $row->{ct_date} }->{'USD'}>=0)
 			     };	
	
	
	}
 	
	
 
	
	if($row->{ct_ex_comis_type} eq 'simple')
	{
# 		die $row->{ct_amnt};
		$row->{currency2}=$row->{e_currency2};
		$row->{currency1}=$row->{orig__ct_currency};
		
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }-=$row->{ct_amnt};
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{result_amnt};
		$row->{ct_amnt}=-$row->{ct_amnt};
		push @$array,$row;
		return;
		
	}
	if($row->{ct_ex_comis_type} eq 'transaction')
	{
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{ct_amnt};
		push @$array,$row;				
		return;
		
	}
	
 	unless($row->{ct_eid})
	{
 	
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{ct_amnt};

		$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }-=$row->{comission};

		$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }-=$row->{ct_ext_commission};
	
 		push @$array,$row;				

 		return;
		
 	}
	if($row->{ct_eid}&&$row->{ct_amnt}>0)
	{
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{result_amnt};
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }-=$row->{ct_ext_commission};
		$row->{currency1}=$row->{orig__ct_currency};
		$row->{currency2}=$row->{e_currency2};
		push @$array,$row;

	}
	else
	{	
		$row->{currency1}=$row->{e_currency2};
		$row->{currency2}=$row->{orig__ct_currency};
		
 		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }-=$row->{result_amnt};
		push @$array,$row;
	
		return;
	}	
	

}
1;
	

