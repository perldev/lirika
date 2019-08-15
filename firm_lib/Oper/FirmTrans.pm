package Oper::FirmTrans;
use strict;
use base 'CGIBaseOut';
use SiteConfig;
use SiteDB;
use SiteCommon;

my $proto;

sub setup
{
  my $self = shift;
  $self->start_mode('list');
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
  );
}

sub get_right
{       
        my $self=shift;
        
        
        my $tmp = get_firms_hash();
        my $hash2 = {};
        my $hash1 = {};
        foreach my $r(%{$tmp})
        {
            $hash2->{$r} = $tmp->{$r}->{title}."(id# ".$tmp->{$r}->{f_id}.")" if($tmp->{$r}->{title});
        }
        $tmp = get_out_firms_hash();
        foreach my $r(%{$tmp})
        {
            $hash1->{$r} = $tmp->{$r}->{title}."(id# ".$tmp->{$r}->{of_id}.")" if($tmp->{$r}->{title});
        }
        
        my @firms;
        
        my $h = get_firms_hash();
        #use Data::Dumper;
        #die(Dumper($h));
        foreach my $r(%{$h})
        {
        	if($h->{$r}->{f_id})
        	{
        	   push @firms,{value=>$h->{$r}->{f_id},title=>$h->{$r}->{title}."(id#".$h->{$r}->{f_id}.")"};
        	}
        }
        
        $proto={
        'table'=>"docs_money",
        'template_prefix'=>"firm_trans",
        'extra_where'=>"ct_status!='deleted' AND ct_currency='UAH' AND ct_req='no' AND ct_fid>0",
        'page_title'=>"Выписка по фирмам",
        'sort'=>'ct_req,ct_date DESC',
        'fields'=>[
            {
            'field'=>"ct_id",
            "title"=>"ID",
            "no_add_edit"=>1
            }, #first field is ID
            {'field'=>"ct_date", 
            "no_add_edit"=>1,
            "no_view"=>1,
            "title"=>"Дата",
            'filter'=>"time"
            },{
                'field'=>"ct_fid", "title"=>"Фирма", "category"=>"firms", 'filter'=>"="
            , "type"=>"select",'without_all'=>1
            },{
                'field'=>"ct_ofid", 
                "title"=>"Фирма клиента",
                "category"=>"out_firms",
                "type"=>"select",
                'filter'=>'=',
                'select_search'=>1
            },{
            'field'=>"ct_from_fid2",
            "title"=>"Фирма",
            #"category"=>"firms",
            'titles'=>\@firms,
            "type"=>"select"
            
            },{
            'field'=>"ct_from_drid", "title"=>"Документы", 
            , "type"=>"select"
            },{
                'field'=>'ct_aid'
            },{ 
                "title"=>"Док-ты год :",
                field=>'doc_period_year',
                type=>'select',
                titles=>&get_years,
                filter=>'='
            },{ 
                "title"=>"Док-ты месяц :",
                field=>'doc_period_month',
                type=>'select',
                titles=>\@months,
                filter=>'='
            }
        ],
        };


 
 
        return 'firm_list';
}

sub list
{
    
    my $self = shift;
    #die "here";
    my $fid=int($self->query->param('ct_fid'));
    $proto->{operator_accounts}=get_oper_accounts_hash($self->{user_id});

    my $month=int($self->query->param('doc_period_month'));

    my $year=int($self->query->param('doc_period_month'));

    $proto->{table}='cashier_transactions' if(!$month&&!$year);
    

    if($fid)    
    {
        my $type=$self->query->param('type_time_filter');
                
        
        my $ref=$dbh->selectrow_hashref(q[SELECT * FROM firms_out_operators 
        WHERE o_id=?  AND f_id=?],undef,$self->{user_id},$fid); 
        unless($ref->{f_id})
        {
            $self->header_type('redirect');
            return $self->header_add(-url=>'firms.cgi?');
        }
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

        my $drids=$dbh->selectall_hashref(qq[SELECT ct_from_drid FROM 
                                             cashier_transactions 
                                             WHERE 
                                             ct_fid=$fid 
                                             AND ct_date>='$filter_where[0]' 
                                             AND  ct_from_drid 
                                             IS NOT NULL
                                             GROUP BY ct_from_drid ],'ct_from_drid');

        
        

        my @refer=keys %$drids;
        my $size=@refer;
        if($size){
              $proto->{fields}->[5]->{titles}=get_docs(\@refer);
        }else{
              $proto->{fields}->[5]->{titles}=[];
        }
  

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
        
        
        my $reqs_sum=$dbh->selectrow_hashref(q[
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
    
    $self->{tpl_vars}->{trans_id} = $TRANSIT_ID;
    $self->{tpl_vars}->{months} = \@months;
    $self->{tpl_vars}->{years} = get_years();
    
    return $self->proto_list($proto,{after_list=>\&last_record,fetch_row=>\&firms_sum});
}
sub last_record
{
    
    ##$prev_row - in our case its date
    my ($array,$row,$prev_row)=@_;
    push @$array,{
        type=>'concl',
        ct_date=>'На начало',
        UAH_FORMAT=>"$proto->{beg_uah}",
#       ct_currency=>"$proto->{beg_usd} USD",
#       ct_comment=>"$proto->{beg_eur} EUR"

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
        push @$array,{type=>'concl',ct_date=>'На конец:',
                      UAH=>$proto->{orig__beg_uah},
                      UAH_FORMAT=>format_float($proto->{orig__beg_uah}),
                    };

    }
    
    
    unless($proto->{sums}->{$row->{ct_date}})
    {
        ##if conclusion calculation for this date
        
        ##
        my %hash;
        $proto->{sums}->{ $row->{ct_date} }=\%hash;
        $proto->{sums}->{ $row->{ct_date} }->{UAH}=$proto->{sums}->{ $prev_row }->{UAH};
        
        push @$array,{type=>'concl',ct_date=>format_date($row->{ct_date}),
                    UAH=>$proto->{sums}->{ $prev_row }->{UAH},
                UAH_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'UAH'}),
                 }; 
    
    }
    $row->{ct_aid}=$proto->{operator_accounts}->{$row->{ct_aid}}->{a_name};
    
    push @$array,$row;

    $proto->{sums}->{ $row->{ct_date} }->{ $row->{ct_currency} }-=$row->{ct_amnt};
    return;
}

1;
