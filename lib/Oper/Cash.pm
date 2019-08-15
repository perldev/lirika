package Oper::Cash;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $RIGHT='cash_in_before';
my $proto;
my $kassa_id=undef;
my $co_id=undef;

sub get_right{
    my $self=shift;
    my $kassa_title;
    $co_id=undef;
    ($kassa_id,$kassa_title,$co_id)=$dbh->selectrow_array(q[SELECT
                                      co_aid,co_title,co_id
                                      FROM cash_offices 
                                      WHERE co_name=?],undef,$self->{cash});  
     $proto={
        'table'=>"cash_".$self->{cash}, 
        'page_title'=>'Сводный учет наличных '.$kassa_title,
        'sort'=>' ct_date,ct_currency ASC',
        'template_prefix'=>"cash",
        'need_confirmation'=>1,
        'fields'=>[
            {'field'=>"ct_date", 'category'=>'date', "title"=>"Дата", 'filter'=>"time"},
            ],
        };
      $proto->{cash}=$kassa_id;
      return 'cash_'.$self->{cash};
}

sub setup
{
  my $self = shift;
  $self->start_mode('list');  
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'non_list' => 'non_list',
    
  );
}
sub non_list
{
   my $self = shift;

   my %hash;
   $self->get_cash_conclusions($proto);	
   
   $proto->{orig__beg_uah}=0;

   $proto->{orig__beg_usd}=0;

   $proto->{orig__beg_eur}=0;
   $proto->{non_list}=1;

   $proto->{sums}=\%hash;
   $proto->{table}='non_cash_'.$self->{cash};	   	
   return $self->proto_list($proto,{fetch_row=>\&cash_sum,after_list=>\&cash_last_record});
}



sub list
{
   my $self = shift;
   $self->get_cash_conclusions($proto);
   $proto->{non_list}=0;
   my %hash;
   $proto->{sums}=\%hash;
   return $self->proto_list($proto,{fetch_row=>\&cash_sum,after_list=>\&cash_last_record});

}


my %tmp_hash;

sub cash_last_record
{
	my ($rows,$r,$prew,$proto)=@_;
 	my %ss;
	map{$ss{$_}=format_float($tmp_hash{$_}) } keys %tmp_hash;
	push 	@$rows,\%ss;
	%tmp_hash=();

 	push @$rows,{type=>'concl',date=>"на конец",
  			      	UAH=>	$proto->{sums}->{ $prew }->{'UAH'},
  			      	USD=>	$proto->{sums}->{ $prew }->{'USD'},
 				EUR=>	$proto->{sums}->{ $prew }->{'EUR'},
 				UAH_FORMAT=>format_float($proto->{sums}->{ $prew }->{'UAH'}),
 				USD_FORMAT=>format_float($proto->{sums}->{ $prew }->{'USD'}),
 				EUR_FORMAT=>format_float($proto->{sums}->{ $prew }->{'EUR'}),
  			     };	
	@$rows=reverse(@$rows); 


}

sub cash_sum
{
	##$prev_row - in our case its date
	my ($array,$row,$prev_row,$proto)=@_;

	my $date=$row->{ct_date};
	unless($prev_row)
	{
		##if the first row begin our calculation
		my %hash;
		$proto->{sums}->{ $date  }=\%hash;
		
		$proto->{sums}->{ $date }->{'UAH'}=$proto->{orig__beg_uah};
		$proto->{sums}->{ $date }->{'USD'}=$proto->{orig__beg_usd};
		$proto->{sums}->{ $date }->{'EUR'}=$proto->{orig__beg_eur};

		$proto->{reports_rate}->{ $date }={rr_rate=>5.05} unless( $proto->{reports_rate}->{$date });

		push @$array,{
				type=>'concl',date=>'На начало :',
				UAH=>$proto->{sums}->{ $date }->{'UAH'},
 			      	USD=>$proto->{sums}->{ $date }->{'USD'},
				EUR=>$proto->{sums}->{ $date }->{'EUR'},
				UAH_FORMAT=>format_float($proto->{sums}->{ $date }->{'UAH'}),
				USD_FORMAT=>format_float($proto->{sums}->{ $date }->{'USD'}),
				EUR_FORMAT=>format_float($proto->{sums}->{ $date }->{'EUR'}),
 				
 			     };
		
				
	}
	
	unless($proto->{sums}->{$date})
	{
		##if conclusion calculation for this date
		my %hash;
		
		$proto->{sums}->{ $date }=\%hash;
		$proto->{sums}->{ $date }->{UAH}=$proto->{sums}->{ $prev_row }->{UAH};
		$proto->{sums}->{ $date }->{USD}=$proto->{sums}->{ $prev_row }->{USD};
		$proto->{sums}->{ $date  }->{EUR}=$proto->{sums}->{ $prev_row }->{EUR};
		

		
		my %ss;
		map{$ss{$_}=format_float($tmp_hash{$_}) } keys %tmp_hash;
		push 	@$array,\%ss;
		%tmp_hash=();

		push @$array,{ type=>'concl',date=>format_date($date),
 			      	UAH=>$proto->{sums}->{ $prev_row }->{UAH},
 			      	USD=>$proto->{sums}->{ $prev_row }->{USD},
				EUR=>$proto->{sums}->{ $prev_row }->{EUR},
				UAH_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'UAH'}),
				USD_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'USD'}),
				EUR_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'EUR'}),
 			     };	
	
	
	}

	
	
			
		$proto->{sums}->{$date}->{ $row->{ct_currency} }+=$row->{ct_amnt};
		if($row->{ct_amnt}>0)
		{
			$tmp_hash{'ct_amnt_'.lc($row->{ct_currency})}=$row->{ct_amnt};
			
		
		}
		else
		{
			$tmp_hash{'ct_amnt_'.lc($row->{ct_currency}.'_mines')}=$row->{ct_amnt};
		
		}	
	
	

 	
	
 
}


1;
