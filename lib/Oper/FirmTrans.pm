package Oper::FirmTrans;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $proto;
sub get_right{       
        my $self=shift;
    

        $proto={
        'table'=>"cashier_transactions",  
        'template_prefix'=>"firm_trans",
        'extra_where'=>"ct_status!='deleted' AND ct_req='no' AND ct_fid>0",
        'page_title'=>"Выписка по фирмам",
        'sort'=>'ct_req,ct_date DESC',
        'fields'=>[
            {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
        
            {'field'=>"ct_date", "no_add_edit"=>1, "no_view"=>1, "title"=>"Дата", 'filter'=>"time"},
        
            {
	        'field'=>"ct_fid", "title"=>"Фирма", "category"=>"firms", 'filter'=>"="
            , "type"=>"select"
            },    
            
        
            {'field'=>"ct_aid", "title"=>"Аккаунт", "category"=>"accounts"},
        
            {'field'=>"ct_amnt", "title"=>"Сумма", "no_add_edit"=>1, 'filter'=>"eq"},
        
            {'field'=>"ct_currency", "title"=>"Валюта", 'filter'=>"="
            , "type"=>"select"
            , "titles"=>\@currencies     
            },
        
            {'field'=>"ct_comment", "title"=>"Назначение", "no_add_edit"=>1,},
        
            {'field'=>"ct_oid", "title"=>"Оператор"
            , "no_add_edit"=>1, "category"=>"operators"
            },
            #{'field'=>"ct_tid", "title"=>"Транзакция", "no_add_edit"=>1,},
        
        
            {'field'=>"ct_status", "title"=>"Статус"
            , "no_add_edit"=>1
            , "no_view"=>1
        
            , "type"=>"select"
        
            , "titles"=>[
            {'value'=>"transit", 'title'=>"транзит"},
                        
                {'value'=>"created", 'title'=>"в процессе"},
                {'value'=>"processed", 'title'=>"идентифицирован"},
                {'value'=>"canceled", 'title'=>"отменен"},
            ]
        
            },
        ],
        };
        return 'firm_list';
}

sub setup
{
  my $self = shift;
  $self->start_mode('list'); 
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',

  );
}



sub list
{
	my $self = shift;
	my $fid=$self->query->param('ct_fid');
	
	my $del_to=$self->query->param('del_to');
	if ($del_to)
	{
	   	$proto->{'extra_where'}=q[  ct_fid>0];
		$proto->{del_to}=1;
	}else
	{
		 $proto->{'extra_where'}=q[ ct_status!='deleted' AND 1 AND ct_fid>0 ];
		 $proto->{del_to}=0;
	}

	if($fid)	
	{
		my $type=$self->query->param('type_time_filter');
				

		my $ref=$dbh->selectrow_hashref(q[SELECT * FROM firms WHERE f_id=?],undef,$fid);	
		map { $proto->{$_}=$ref->{$_} } keys %$ref;
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
		SELECT sum(ct_amnt) 
		FROM cashier_transactions 
		WHERE  ct_fid=? 
		AND ct_currency='UAH' AND ct_status!='deleted' AND ct_req='no'
		 AND  ct_date>=? GROUP BY ct_fid) as UAH,
		( 
		SELECT sum(ct_amnt) 
		FROM cashier_transactions 
		WHERE  ct_fid=? AND ct_status!='deleted' AND ct_req='no'
		AND ct_currency='USD'  
		 AND ct_date>=? GROUP BY ct_fid) as USD, 
		(
		SELECT sum(ct_amnt) 
		FROM cashier_transactions
		WHERE   ct_fid=? 
		AND 
		ct_currency='EUR' AND ct_status!='deleted' AND ct_req='no'
		AND ct_date>=? 
		GROUP BY ct_fid

		) as EUR
		],undef,
		$fid,
		$filter_where[0],
		$fid,
		$filter_where[0],
		$fid,
		$filter_where[0]
		);
		
		my $to=$dbh->selectrow_hashref(q[
		SELECT  
		(
		SELECT sum(ct_amnt) 
		FROM cashier_transactions 
		WHERE  ct_fid=?
		AND ct_currency='UAH' AND ct_status!='deleted' AND ct_req='no'
		AND ct_date>=? AND ct_date<=?  GROUP BY ct_fid) as UAH,
		( 
		SELECT sum(ct_amnt) 
		FROM cashier_transactions 
		WHERE  ct_fid=? AND ct_status!='deleted' AND ct_req='no'
		AND ct_currency='USD' 
		AND  ct_date>=? AND ct_date<=? GROUP BY ct_fid) as USD, 
		(

		SELECT sum(ct_amnt) 
		FROM cashier_transactions
		WHERE  ct_fid=? AND ct_status!='deleted' AND ct_req='no'
		AND
		ct_currency='EUR' 
		AND ct_date>=? AND ct_date<=?
		GROUP BY ct_fid

		) as EUR
		],undef,
		$fid,
		$filter_where[0],
		$filter_where[1],
		$fid,
		$filter_where[0],
		$filter_where[1],
		$fid,
		$filter_where[0],
		$filter_where[1]
		);
		

		my $reqs_sum=
		$dbh->selectrow_hashref(q[
		SELECT  
		(
		SELECT sum(ct_amnt) 
		FROM cashier_transactions 
		WHERE  ct_fid=?
		AND ct_currency='UAH' AND ct_status!='deleted' AND ct_req='yes'
		AND ct_date>=? AND ct_date<=?  GROUP BY ct_fid) as UAH,
		( 
		SELECT sum(ct_amnt) 
		FROM cashier_transactions 
		WHERE  ct_fid=? AND ct_status!='deleted' AND ct_req='yes'
		AND ct_currency='USD' 
		AND  ct_date>=? AND ct_date<=? GROUP BY ct_fid) as USD, 
		(

		SELECT sum(ct_amnt) 
		FROM cashier_transactions
		WHERE  ct_fid=? AND ct_status!='deleted' AND ct_req='yes'
		AND
		ct_currency='EUR' 
		AND ct_date>=? AND ct_date<=?
		GROUP BY ct_fid

		) as EUR
		],undef,
		$fid,
		$filter_where[0],
		$filter_where[1],
		$fid,
		$filter_where[0],
		$filter_where[1],
		$fid,
		$filter_where[0],
		$filter_where[1]
		);
		
		$proto->{beg_uah}=$ref->{f_uah}-$from->{UAH};
		$proto->{beg_usd}=$ref->{f_usd}-$from->{USD};
		$proto->{beg_eur}=$ref->{f_eur}-$from->{EUR};

		$proto->{fin_uah}=$proto->{beg_uah}+$to->{UAH}+$reqs_sum->{UAH};
		$proto->{fin_usd}=$proto->{beg_usd}+$to->{USD}+$reqs_sum->{USD};
		$proto->{fin_eur} =$proto->{beg_eur}+$to->{EUR}+$reqs_sum->{EUR};
		
			

		$proto->{orig__beg_uah}=$proto->{fin_uah};
		$proto->{orig__beg_usd}=$proto->{fin_usd};
		$proto->{orig__beg_eur}=$proto->{fin_eur};		
	
		$proto->{fin_uah}=format_float($proto->{fin_uah}); 
		$proto->{fin_usd}=format_float($proto->{fin_usd});
		$proto->{fin_eur}=format_float($proto->{fin_eur});
	
		

		$proto->{beg_uah}=format_float($proto->{beg_uah});
		$proto->{beg_usd}=format_float($proto->{beg_usd});
		$proto->{beg_eur}=format_float($proto->{beg_eur});		

		$proto->{from_date}=format_date($filter_where[0]);
		$proto->{to_date}=format_date($filter_where[1]);
		
	}
	my %hash;
	$proto->{sums}=\%hash;
 	return $self->proto_list($proto,{after_list=>\&last_record,fetch_row=>\&firms_sum});
}
sub last_record
{
	
	##$prev_row - in our case its date
	my ($array,$row,$prev_row)=@_;
 	push @$array,{

		ct_date=>'На начало',
		ct_amnt=>"$proto->{beg_uah} ГРН",
		ct_currency=>"$proto->{beg_usd} USD",
		ct_comment=>"$proto->{beg_eur} EUR"

	};	


}
sub firms_sum
{
	my ($array,$row,$prev_row,$proto)=@_;
	unless($prev_row)
	{
		##if the first row begin our calculation
		my %hash;
		$proto->{sums}->{ $row->{ct_date} }=\%hash;
		$proto->{sums}->{ $row->{ct_date} }->{'UAH'}=$proto->{orig__beg_uah};
		$proto->{sums}->{ $row->{ct_date} }->{'USD'}=$proto->{orig__beg_usd};
		$proto->{sums}->{ $row->{ct_date} }->{'EUR'}=$proto->{orig__beg_eur};
		push @$array,{type=>'concl',ct_date=>'На конец(с заявками) :',
 			      	UAH=>$proto->{orig__beg_uah},
 			      	USD=>$proto->{orig__beg_usd},
				EUR=>$proto->{orig__beg_eur},
				UAH_FORMAT=>format_float($proto->{orig__beg_uah}),
				USD_FORMAT=>format_float($proto->{orig__beg_usd}),
				EUR_FORMAT=>format_float($proto->{orig__beg_eur}),
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

		push @$array,{type=>'concl',ct_date=>format_date($row->{ct_date}),
 			      	UAH=>$proto->{sums}->{ $prev_row }->{UAH},
 			      	USD=>$proto->{sums}->{ $prev_row }->{USD},
				EUR=>$proto->{sums}->{ $prev_row }->{EUR},
				UAH_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'UAH'}),
				USD_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'USD'}),
				EUR_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'EUR'}),
 			     };	
	
	}

	
	push @$array,$row;
	$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }-=$row->{ct_amnt};
	
	



	return;
}

1;
