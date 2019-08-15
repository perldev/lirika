package Oper::FirmTransUSD;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;


my (%hash_uah_usd,%hash_eur_usd,%one_hash);

my $proto={
  'table'=>"cashier_transactions",  
  'template_prefix'=>"firm_trans_usd",
  'extra_where'=>"ct_status!='deleted' AND ct_req='no' AND ct_fid>0",
  'page_title'=>"Выписка по фирмам",
  'sort'=>'ct_req,ct_date ASC',
  'fields'=>[
    {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID

    {'field'=>"ct_date", "no_add_edit"=>1, "no_view"=>1, "title"=>"Дата", 'filter'=>"time"},

    {
	'field'=>"ct_fid", "title"=>"Фирма", "category"=>"firms", 'filter'=>"="
      , "type"=>"select"
    },    
    

    {'field'=>"ct_aid", "title"=>"Аккаунт", "category"=>"accounts"},

    {'field'=>"ct_amnt", "title"=>"Сумма", "no_add_edit"=>1, 'filter'=>"="},

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
	
        return 'firm_list';
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
		
=pod
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
=cut        
        	
	    
        &get_hash_of_rates(\%hash_uah_usd,\%hash_eur_usd);
        $one_hash{EUR}=\%hash_eur_usd;
        $one_hash{UAH}=\%hash_uah_usd;
    
		$proto->{beg_uah}=$ref->{f_uah}-$from->{UAH};
		$proto->{beg_usd}=$ref->{f_usd}-$from->{USD};
		$proto->{beg_eur}=$ref->{f_eur}-$from->{EUR};

		$proto->{fin_uah}=$proto->{beg_uah}+$to->{UAH};
		$proto->{fin_usd}=$proto->{beg_usd}+$to->{USD};
		$proto->{fin_eur} =$proto->{beg_eur}+$to->{EUR};
		
			

		$proto->{orig__beg_uah}=$proto->{beg_uah};
		$proto->{orig__beg_usd}=$proto->{beg_usd};
		$proto->{orig__beg_eur}=$proto->{beg_eur};		
	
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
sub my_add_exch
{
    my ($array,$sum,$from,$prev_row,$proto)=@_;

    my $result=$one_hash{$from}->{$prev_row}*$sum;
    $proto->{sums}->{ $prev_row }->{$from}-=$sum;
    $proto->{sums}->{ $prev_row }->{USD}+=$result;
    my $d;
=pod
          $d={
             ct_id=>1,
             ct_currency=>$from,
             orig__ct_currency=>$from,
             col_status=>'no',
             ct_amnt=>-$sum,
             ct_fid=>'Exchange',
             orig__ct_amnt=>-$sum,
             ct_date=>$prev_row,
             orig__ct_date=>$prev_row,
             ct_status=>'processed',
             id=>1,
             ct_ex_comis_type=>'input'
            };
    

    push @$array,$d;
             $d={
             ct_id=>1,
             ct_currency=>'USD',
             orig__ct_currency=>'USD',
             col_status=>'no',
             ct_fid=>'Exchange',
             ct_amnt=>$result,
             orig__ct_amnt=>$result,
             ct_date=>$prev_row,
             orig__ct_date=>$prev_row,
             ct_status=>'processed',
             id=>1,
             ct_ex_comis_type=>'input'
                    };

    push @$array,$d;

=cut
    
        

    
}

sub last_record
{
	
	##$prev_row - in our case its date
	my ($array,$row,$prev_row)=@_;
    my_add_exch($array,$proto->{sums}->{ $prev_row }->{UAH},'UAH',$prev_row,$proto);
    my_add_exch($array,$proto->{sums}->{ $prev_row }->{EUR},'EUR',$prev_row,$proto);
    push @$array,{

		ct_date=>'На конец',
		ct_amnt=>"$proto->{sums}->{ $prev_row }->{UAH} ГРН",
		ct_currency=>"$proto->{sums}->{ $prev_row }->{USD} USD",
		ct_comment=>"$proto->{sums}->{ $prev_row }->{EUR} EUR"

	};
    @$array=reverse(@$array);
    $dbh->do(q[UPDATE firms SET f_usd_eq=? WHERE f_id=?],undef,$proto->{sums}->{ $prev_row }->{USD},$proto->{f_id});
    



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
=pod	
    	push @$array,{
                    type=>'concl',ct_date=>'На начало(с заявками) :',
 			      	UAH=>$proto->{orig__beg_uah},
 			      	USD=>$proto->{orig__beg_usd},
				    EUR=>$proto->{orig__beg_eur},
				    UAH_FORMAT=>format_float($proto->{orig__beg_uah}),
				    USD_FORMAT=>format_float($proto->{orig__beg_usd}),
				    EUR_FORMAT=>format_float($proto->{orig__beg_eur}),
 			     };	
=cut		
		


	}
	unless($proto->{sums}->{$row->{ct_date}})
	{
		##if conclusion calculation for this date
		
		##
		my %hash;
        my_add_exch($array,$proto->{sums}->{ $prev_row }->{UAH},'UAH',$prev_row,$proto);
        my_add_exch($array,$proto->{sums}->{ $prev_row }->{EUR},'EUR',$prev_row,$proto);


		$proto->{sums}->{ $row->{ct_date} }=\%hash;
		$proto->{sums}->{ $row->{ct_date} }->{UAH}=$proto->{sums}->{ $prev_row }->{UAH};
		$proto->{sums}->{ $row->{ct_date} }->{USD}=$proto->{sums}->{ $prev_row }->{USD};
		$proto->{sums}->{ $row->{ct_date} }->{EUR}=$proto->{sums}->{ $prev_row }->{EUR};
        

=pod    

		push @$array,{type=>'concl',ct_date=>format_date($row->{ct_date}),
 			      	UAH=>$proto->{sums}->{ $prev_row }->{UAH},
 			      	USD=>$proto->{sums}->{ $prev_row }->{USD},
				    EUR=>$proto->{sums}->{ $prev_row }->{EUR},
				UAH_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'UAH'}),
				USD_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'USD'}),
				EUR_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'EUR'}),
 			     };	
=cut
	}

	
#	push @$array,$row;

	$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{ct_amnt};
	
	return;
}
sub get_hash_of_rates
{
    my ($hash_uah_usd,$hash_eur_usd)=@_;
    
    my @u;
    open(FL,'usd');

    @u=<FL>;

    close(FL);

    my @debug;
    foreach(@u)
    {
    
        my $tmp=$_;
        next unless($tmp);

        $tmp=~s/[ ]+|\t/ /g;
        $tmp=~s/[ ]+/ /g;
        push @debug,$tmp;
    
        my @t=split(/ /,$tmp);
     
        get_date(\$t[0]);
        get_rate(\$t[2]);
         unless($t[2])
         {
             die $_;
             die "inner $_";
         }
        

        $hash_uah_usd->{$t[0]}=1/$t[2];
       }  
     #  print (@debug == keys %$hash_uah_usd);
       
        @u=();
        @debug=();

        open(FL,'eur');

        @u=<FL>;

          close(FL);
          foreach(@u)
          {
        
                my $tmp=$_;
         
                $tmp=~s/[ ]+|\t/ /g;
                $tmp=~s/[ ]+/ /g;
                push @debug,$tmp;
                next unless($tmp);
                my @t=split(/ /,$tmp);
            
                get_date(\$t[0]);
                get_rate(\$t[2]);
                unless($t[2])
                {
                 
                    die "inner $_";
                }
                $hash_eur_usd->{$t[0]}=($hash_uah_usd->{$t[0]}/(1/$t[2]) );
                #print "$t[0] - $t[2] - $hash_eur_usd->{$t[0]} \n";
           }  
      
       # print (@debug == keys %$hash_eur_usd);
}
sub get_rate
{
    my $ref=shift;
    my $tmp=$ref;
    $$ref=~/\((.+)\)/;
    $$ref=$1;
    

}

sub get_date
{
    my $d=shift;

    $$d=~/(\d+)\.(\d+)\.(\d+)|(\d+)\/(\d+)\/(\d+)/;
        my $tmp;

    if($1)
    {
         $tmp+=$3;
         $tmp+=2000 if($tmp<1900);
         $$d="$tmp-$2-$1";
        return ;    

    }
    
    if($4)
    {
        $tmp=$6;

        $tmp+=2000 if($tmp<1900);

        $$d="$tmp-$5-$4";
        return ;

    }

}




1;
