package Oper::AccountsReportsUSD;
use strict;
use base 'CGIBase';
use SiteConfig;
use Data::Dumper;
use SiteDB;
use SiteCommon;
#    {'field'=>"ts", 'category'=>'date', "title"=>"Дата", 'filter'=>"time"},

my $proto={
  'table'=>"accounts_reports_table",  
  'template_prefix'=>"accounts_reports_usd",
  'page_title'=>"Выписка по клиентам",
  'sort'=>'ts ASC ',
   
   'fields'=>[
    {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
    {'field'=>"ct_fid", "title"=>"Фирма", "category"=>"firms", 'filter'=>"="
      , "type"=>"select"
    },
    {'field'=>"ct_aid", "title"=>"Карточка",'type'=>'select',
    'titles'=>&get_accounts_simple(),
    'filter'=>'='},
    {'field'=>"ct_amnt", "title"=>"Сумма", "no_add_edit"=>1, 'filter'=>"="},
    {'field'=>"ct_currency", "title"=>"Валюта", 'filter'=>"="
     , "type"=>"select","titles"=>\@currencies },
    {'field'=>"ct_comment", "title"=>"Назначение", "no_add_edit"=>1,},

    {'field'=>"ct_oid", "title"=>"Оператор" , "no_add_edit"=>1, "category"=>"operators"},
  ],
};

my (%one_hash,$SELF,$PREV_RATE);




sub setup
{
   my $self = shift;
#####
   
#  die  $self->query->param('do');
   $self->run_modes(
        'AUTOLOAD'   => 'list',
        'list' => 'list',
        
    );
}
sub list
{
    my $self = shift;
    my $del_to=$self->query->param('del_to');
    if ($del_to)
    {
        $proto->{'extra_where'}='';
        $proto->{del_to}=1;
    }else
    {
         $proto->{'extra_where'}=q[ ct_status!='deleted' ];
        $proto->{del_to}=0;
    }

    my $start_amnts;
    my $fid=$self->query->param('ct_aid');
    if($fid)    
    {
        my $type=$self->query->param('type_time_filter');

        my $ref=$dbh->selectrow_hashref(q[SELECT * FROM accounts WHERE a_id=?],undef,$fid); 
        
        my $row=$dbh->selectrow_array(q[SELECT ah_ts FROM accounts_history 
        WHERE ah_aid=? ORDER BY ah_id DESC LIMIT 1],undef,$fid);    

        map { $proto->{$_}=format_float($ref->{$_}) } keys %$ref;

        $proto->{a_name}=$ref->{a_name};

        my @filter_where;
        push @filter_where,$row if($proto->{table} eq 'accounts_reports_table');
        $filter_where[0]='0000-00-00 00:00:00' unless($filter_where[0]);
        my $sums={};
            
            
            
            
        my $sums=calculate_sum_with(
                {
                    a_id=>$fid,
                    date_from=>$filter_where[0],
                    date_to=>$filter_where[1],
                    date2=>" 1 ",
                    date1=>' 1 ',   
#                   date1=>"ts>'$filter_where[0]'",
                    table=>$proto->{table}
                }
                );
        

        my ($hash_uah_usd,$hash_eur_usd)=&get_hash_of_rates();
       
        $one_hash{EUR}=$hash_eur_usd;
        $one_hash{UAH}=$hash_uah_usd;
        
#       use Data::Dumper;
#           die Dumper $sums;

        
        $proto->{beg_uah}=$ref->{a_uah}-$sums->{UAH};

        $proto->{beg_usd}=$ref->{a_usd}-$sums->{USD};#$ref->{a_usd}-$from->{USD};

        $proto->{beg_eur}=$ref->{a_eur}-$sums->{EUR};


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


         $proto->{'ct_aid'}=$fid;
         $proto->{'sort'}=' ts ASC';
     my %hash;
    
    $proto->{sums}=\%hash;      
    $PREV_RATE={EUR=>{},UAH=>{}};    
#       die Dumper $proto;
    $SELF=$self;
    return $self->proto_list($proto,{fetch_row=>\&sumss,after_list=>\&last_recordss});


}
sub get_hash_of_rates
{
    my ($ref1,$ref2);
    $ref1=$dbh->selectall_hashref('SELECT sr_date,sr_uah_domi as UAH_DOMI,sr_uah_nal as UAH 
                                    FROM system_rates ','sr_date');
    $ref2=$dbh->selectall_hashref('SELECT sr_date,sr_eur_nal AS EUR,sr_eur_nal AS EUR_DOMI
                                            FROM system_rates ','sr_date');
    return ($ref1,$ref2)
}
sub sumss
{
    ##$prev_row - in our case its date
    my ($array,$row,$prev_row,$proto)=@_;
#    use Data::Dumper;
#    die Dumper    $row;
    unless($prev_row)
    {
        ##if the first row begin our calculation
        my %hash;
        $proto->{sums}->{ $row->{ct_date} }=\%hash;
        $proto->{sums}->{ $row->{ct_date} }->{'UAH'}=$proto->{orig__beg_uah};
        $proto->{sums}->{ $row->{ct_date} }->{'USD'}=$proto->{orig__beg_usd};
        $proto->{sums}->{ $row->{ct_date} }->{'EUR'}=$proto->{orig__beg_eur};
        $proto->{reports_rate}->{ $row->{ct_date} }={rr_rate=>5.05} unless( $proto->{reports_rate}->{ $row->{ct_date} });

  
    }
    unless($proto->{sums}->{$row->{ct_date}})
    {
	
 
         my_add_exch($array,$proto->{sums}->{ $prev_row }->{cash}->{UAH},'UAH',$prev_row,$proto);
         my_add_exch($array,$proto->{sums}->{ $prev_row }->{EUR},'EUR',$prev_row,$proto);
         my_add_exch($array,$proto->{sums}->{ $prev_row }->{UAH}-$proto->{sums}->{ $prev_row }->{cash}->{UAH},'UAH',$prev_row,$proto,1);

        my %hash;
        
        $proto->{sums}->{ $row->{ct_date} }=\%hash;

        $proto->{sums}->{ $row->{ct_date} }->{cash}={};

        $proto->{sums}->{ $row->{ct_date} }->{UAH}=$proto->{sums}->{ $prev_row }->{UAH};
        $proto->{sums}->{ $row->{ct_date} }->{USD}=$proto->{sums}->{ $prev_row }->{USD};
        $proto->{sums}->{ $row->{ct_date} }->{EUR}=$proto->{sums}->{ $prev_row }->{EUR};
    
        $proto->{reports_rate}->{ $row->{ct_date} }={rr_rate=>5.05} unless( $proto->{reports_rate}->{ $row->{ct_date} });
	
	$PREV_RATE->{UAH}=$one_hash{UAH}->{$prev_row};
	$PREV_RATE->{EUR}=$one_hash{EUR}->{$prev_row};                                                                                                        
	                                                       
	
        push @$array,{ct_ex_comis_type=>'concl',ct_date=>format_date($row->{ct_date}),
                    UAH=>$proto->{sums}->{ $row->{ct_date} }->{'UAH'},
                    USD=>$proto->{sums}->{ $row->{ct_date} }->{'USD'},
                EUR=>$proto->{sums}->{ $row->{ct_date} }->{'EUR'},
                UAH_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'UAH'}),
                USD_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'USD'}),
                EUR_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'EUR'}),
                REPORT_UAH=>
                $proto->{sums}->{ $row->{ct_date} }->{'UAH'}/$proto->{reports_rate}->{ $row->{ct_date} }->{rr_rate},
                concl_color=>($proto->{sums}->{ $row->{ct_date} }->{'UAH'}/$proto->{reports_rate}->{$row->{ct_date} }->{rr_rate} +
                $proto->{sums}->{ $row->{ct_date} }->{'USD'})>=-0.001
                 };
        


   
    }
                                                                   
    $row->{col_color}=sprintf('#%x',$row->{col_color});

    return if($row->{ct_status} eq 'deleted');
    

    
    if($row->{ct_ex_comis_type} eq 'simple')
    {
#       die $row->{ct_amnt};
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

        $row->{search_url}="trans.cgi?t_id=$row->{ct_id}&amp;action=filter&amp;t_date= this_year";
        push @$array,$row;

        return;
        
    }
    
    unless($row->{ct_eid})
    {
        
        if($row->{ct_fid}==-2)
        {
              $proto->{sums}->{ $row->{ct_date} }->{cash}->{ $row->{orig__ct_currency}}+=$row->{ct_amnt};

              $proto->{sums}->{ $row->{ct_date} }->{cash}->{ $row->{orig__ct_currency} }+=$row->{comission};

              $proto->{sums}->{ $row->{ct_date} }->{cash}->{ $row->{orig__ct_currency} }+=$row->{ct_ext_commission};

        }
	
	    $proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency}}+=$row->{ct_amnt};

        $proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{comission};

        $proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{ct_ext_commission};



              push @$array,$row;


        return;
        
    }
    if($row->{ct_eid}&&$row->{ct_amnt}>0)
    {
        $proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{result_amnt};
        $proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{ct_ext_commission};
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
sub last_recordss
{
    my ($rows,$r,$prew,$proto)=@_;

    $proto->{reports_rate}->{$prew} ={rr_rate=>5.05} unless( $proto->{reports_rate}->{ $prew }); 
    $proto->{beg_uah}=$proto->{beg_uah};
    $proto->{beg_usd}=$proto->{beg_usd};
    $proto->{beg_eur}=$proto->{beg_eur};    

    my $a_info=$dbh->selectrow_hashref(q[SELECT * FROM accounts WHERE a_id=?],undef,$proto->{'ct_aid'});
      

    unless( defined($prew) )   
    {
            
        $proto->{a_uah}=format_float($a_info->{a_uah});
        $proto->{a_usd}=format_float($a_info->{a_usd});
        $proto->{a_eur}=format_float($a_info->{a_eur});
        
        $proto->{non_a_uah}=$a_info->{a_uah};
        $proto->{non_a_usd}=$a_info->{a_usd};
        $proto->{non_a_eur}=$a_info->{a_eur};
        $proto->{control_sum}=$a_info->{a_uah}+$a_info->{a_usd}+$a_info->{a_eur};
        
        $proto->{control_sum_exist}=$a_info->{a_uah}+$a_info->{a_usd}+$a_info->{a_eur};
        $proto->{control_sum_exist_fin}=$proto->{orig__beg_uah}+$proto->{orig__beg_usd}+$proto->{orig__beg_eur};
        $dbh->do(q[UPDATE accounts 
        SET a_usd_eq=? 
        WHERE a_id=?
        ],undef,
        $proto->{orig__beg_usd},
        $proto->{ct_aid});

    
        $proto->{fin_uah}=format_float($proto->{orig__beg_uah});
        $proto->{fin_usd}=format_float($proto->{orig__beg_usd});
        $proto->{fin_eur}=format_float($proto->{orig__beg_eur});     
   
    
    }else
    {


                
         my_add_exch($rows,$proto->{sums}->{ $prew }->{cash}->{UAH},'UAH',$prew,$proto);
         my_add_exch($rows,$proto->{sums}->{ $prew }->{EUR},'EUR',$prew,$proto);
         my_add_exch($rows,$proto->{sums}->{ $prew }->{UAH}-$proto->{sums}->{ $prew }->{cash}->{UAH},'UAH',$prew,$proto,1);
#         my_add_exch($rows,$proto->{sums}->{ $prew }->{EUR}-$proto->{sums}->{ $prew }->{cash}->{EUR},'EUR',$prew,$proto);


        @$rows=reverse(@$rows); 
       
        $proto->{a_uah}=format_float($a_info->{a_uah});
        $proto->{a_usd}=format_float($a_info->{a_usd});
        $proto->{a_eur}=format_float($a_info->{a_eur});
        
        $proto->{non_a_uah}=$a_info->{a_uah};
        $proto->{non_a_usd}=$a_info->{a_usd};
        $proto->{non_a_eur}=$a_info->{a_eur};

        $proto->{control_sum_exist}=$a_info->{a_uah}+$a_info->{a_usd}+$a_info->{a_eur};
        $proto->{control_sum_exist_fin}=$proto->{sums}->{ $prew }->{'UAH'}+$proto->{sums}->{ $prew }->{'USD'}+$proto->{sums}->{ $prew }->{'EUR'};

        
        $dbh->do(q[UPDATE accounts 
        SET a_usd_eq=? 
        WHERE a_id=?
        ],undef,
            $proto->{sums}->{$prew}->{'USD'},
	        $proto->{ct_aid}
        );


        $proto->{fin_uah}=format_float($proto->{sums}->{ $prew }->{'UAH'});
        $proto->{fin_usd}=format_float($proto->{sums}->{ $prew }->{'USD'});
        $proto->{fin_eur}=format_float($proto->{sums}->{ $prew }->{'EUR'});
#       use Data::Dumper;
#       die Dumper $proto;
    
#       $dbh->do(q[UPDATE accounts SET a_uah=?,a_usd=?,a_eur=? WHERE a_id=?],undef,$proto->{sums}->{ $prew }->{'UAH'},$proto->{sums}->{ $prew }->{'USD'},$proto->{sums}->{ $prew }->{'EUR'},$proto->{ct_aid});
            
    }

    
 




}
sub get_right
{       
        my $self=shift;
        return 'account';
}
sub my_add_exch
{
        my ($arr,$sum,$from,$prev_row,$proto,$beznal) =@_;
        my $d={};
	return	unless($sum);
	
        if($prev_row)
        {
    	
        
	    my $rate;
            unless($one_hash{$from}->{$prev_row})
	    {
	
		
		 $one_hash{UAH}->{$prev_row}=$dbh->selectrow_hashref(qq[SELECT sr_date,sr_uah_domi as UAH_DOMI,sr_uah_nal as UAH                                                                  
	                                     FROM system_rates WHERE sr_date<'$prev_row' ORDER BY sr_date DESC LIMIT 1]);
    	         $one_hash{EUR}->{$prev_row}=$dbh->selectrow_hashref(qq[SELECT sr_date,sr_eur_domi as EUR_DOMI,sr_eur_nal as EUR                             
                                                  FROM system_rates WHERE sr_date<'$prev_row' ORDER BY sr_date DESC LIMIT 1]); 
	
			
		
		
		
					     
	
	    }	

	unless($one_hash{$from}->{$prev_row})
	{
	
		
	       $one_hash{UAH}->{$prev_row}=$dbh->selectrow_hashref(qq[SELECT sr_date,sr_uah_domi as UAH_DOMI,sr_uah_nal as UAH                             
					                                      FROM system_rates WHERE sr_date>'$prev_row' ORDER BY sr_date ASC  LIMIT 1]);                                                          
	       $one_hash{EUR}->{$prev_row}=$dbh->selectrow_hashref(qq[SELECT sr_date,sr_eur_domi as EUR_DOMI,sr_eur_nal as EUR                             
					                                         FROM system_rates WHERE sr_date>'$prev_row' ORDER BY sr_date ASC  LIMIT 1]);          
	      
	
	
	}
	
	
	
#	die $prev_row	unless($one_hash{$from}->{$prev_row}->{$from});

	my $normal_rate=0;
        unless($beznal){

            if($from eq 'UAH'){
#                         use Data::Dumper;   
#                         die Dumper $one_hash{$from}->{$prev_row};
			$normal_rate=$one_hash{$from}->{$prev_row}->{$from}; 
                        eval{$rate=1/$one_hash{$from}->{$prev_row}->{$from}};
	
                }else{
			$normal_rate=$one_hash{$from}->{$prev_row}->{$from};
                        eval{$rate=$one_hash{$from}->{$prev_row}->{$from}};
	 
                }


        }else{
	    #$normal_rate=$one_hash{$from}->{$prev_row}->{$from."_DOMI"}; 		
	    
            if($from eq 'UAH'){
	         $normal_rate=$one_hash{$from}->{$prev_row}->{$from."_DOMI"};
                eval {$rate=1/$one_hash{$from}->{$prev_row}->{$from."_DOMI"}};
		
		 die Dumper  $one_hash{$from}->{$prev_row},$from  if($@); 
            }else{
		$normal_rate=$one_hash{$from}->{$prev_row}->{$from}; 	
                eval{$rate=$one_hash{$from}->{$prev_row}->{$from}};
		die Dumper  $one_hash{$from}->{$prev_row},$from  if($@); 
		
            }

        }
    
        	    my $result=$normal_rate*$sum;
		
                $proto->{sums}->{ $prev_row }->{$from}-=$sum;
                $proto->{sums}->{ $prev_row }->{USD}+=$result;
        

                $SELF->add_exc({ 
                e_date=>$prev_row,
                e_currency1=>$from,
                e_currency2=>'USD',
                rate=>$rate,
                type=>'system',
                e_amnt1=>$sum,
                e_comment=>'exchanging to USD system cards ',
                a_id=>$proto->{'ct_aid'}
                 });

=pod
		use Data::Dumper;
		die Dumper {                                                                                                                             
		                e_date=>$prev_row,                                                                                                                           
		                e_currency1=>$from,                                                                                                                          
		                e_currency2=>'USD',                                                                                                                          
		                rate=>1/$rate,                                                                                                                                 
		                type=>'system',                                                                                                                              
		                e_amnt1=>$sum,                                                                                                                               
		                e_comment=>'exchanging to USD system cards ',                                                                                                
		                a_id=>$proto->{'ct_aid'}
				 };
=cut
                    $d={
                        ct_date=>$prev_row,
                        ct_currency=>$from,
                        orig__ct_currency=>$from,
                        e_currency2=>'USD',
			            col_status=>'no',
                    		    ct_amnt=>-$sum,
			            rate=>$rate,
			            orig__ct_amnt=>-$sum,
	                            result_amnt=>$result,
			            ct_eid=>1,
			            orig__ct_fid=>-2,
			            ct_fid=>'EXCHANGE',
			            ct_status=>'processed',
			            orig__ct_id=>1,
			            id=>1,
			            ct_ex_comis_type=>'simple'
                    };

         }
      push @{$arr},$d;

        

}



1;
    

