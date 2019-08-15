package Oper::Transit;
use strict;
#use Oper qw( get_trans_list);
use Rights qw( get_rights );
use base q[CGIBase];
use SiteCommon;
use SiteConfig;
use SiteDB;
my $_POST={};#the main aim og this variable is the using by errors
	
		# {'field'=>"f_id1", "title"=>"Фирма получатель", 'filter'=>"",
		#	"category"=>"firms", 'filter'=>"=","type"=>"select"}, 
	#	 {'field'=>"f_id2", "title"=>"Фирма отправитель",
		#	"category"=>"firms", 'filter'=>"=","type"=>"select"}, 


my $proto;

sub get_right{
       my $self=shift;
        $_POST={};
        $proto={
        fields=>
        [   
                        {'field'=>"date", "title"=>"Дата", 'filter'=>"time"},
                        {'field'=>"amnt", "title"=>"Сумма", 'filter'=>"eq"},
                        {'field'=>"currency", "title"=>"Валюта", "type"=>"select", 
                        "titles"=>\@currencies , 'filter'=>"="
                }
            ]
        
        };
        map{$_POST->{$_}=trim($self->query->param($_))} $self->query->param();
        $_POST->{currencies}=$self->{tpl_vars}->{currencies};
       return 'transit';
}
sub setup 
{
        my $self=shift;
	
	$self->start_mode('list');        
	$self->run_modes(
				'AUTOLOAD'=>'trans_list',
                        	'trans_list'=>'trans_list',
                        	'oper_add_trans'=>'oper_add_trans',
				'del'=>'del'
		         );   
        


}

sub trans_list
{
         my $self=shift;
         my $page=$self->query->param('page');
         my $how=$self->query->param('how');
         
         my $filter_where = " 1 ";
         my $filter_params = {};
         if($self->query->param('action') eq 'filter')
         {
                        map {$filter_params->{$_}=$self->query->param($_)} $self->query->param();
         }
        
         $page=0 unless($page);
         $how=40 unless($how);

        if($_POST->{'f_id'})
        {
	
		$self->{tpl_vars}->{trans_list}->{f_id}=$_POST->{f_id};
		my $hash=$dbh->selectrow_hashref(q[SELECT  f_name,f_uah,f_usd,f_eur,f_id FROM  
			firms WHERE f_id=?],undef,$_POST->{f_id});
	
		$self->{tpl_vars}->{trans_list}->{f_name} =$hash->{f_name};
		$self->{tpl_vars}->{trans_list}->{f_uah} =$hash->{f_uah};
		$self->{tpl_vars}->{trans_list}->{f_usd} =$hash->{f_usd};
		$self->{tpl_vars}->{trans_list}->{f_eur} =$hash->{f_eur};
		$self->{tpl_vars}->{trans_list}->{f_id} =$hash->{f_id};
		
	##exception for kassa
        	$_POST->{'color'}="=$_POST->{'f_id'}";
        
	}else
        {
                $_POST->{'color'}='=0';
        }
        

########From oleg
	
	foreach my $row( @{$proto->{fields}} ){
		if($row->{type} eq 'select'){
		my %select=();
				foreach my $option( @{$row->{titles}} )
				{
					$select{ $option->{value} } = $option->{title};
				}
			
				$row->{ "titles_hash" } = \%select;     
			}
		
		if(defined $row->{filter}){
			my $filter_val = "".$filter_params->{ $row->{field} };
			my $filter_val_empty = length($filter_val)==0;
			
			if($row->{filter} eq 'time' && $filter_val_empty){
				$filter_val = "all_time";
				$filter_val_empty = 0;         
			}
			
			#die "$row->{filter} - '$filter_val' - $filter_val_empty";
			
			if(!$filter_val_empty){
				$row->{value}=$filter_val;
			
				if($row->{filter} eq 'time'){
					my $res = time_filter($filter_val);
					
					$filter_where .= " AND '$res->{start}'<=$row->{field} AND '$res->{end}'>=$row->{field}";
				}elsif($row->{filter} eq 'like')
				{
					$filter_where .= " AND lcase($row->{field}) like lcase(".sql_val($filter_val.'%').")";
				
				}else{
				
					$filter_val=~s/[ "'\\]//g;
					$filter_val=~s/[, ]/\./g;
				if($row->{field} eq 'amnt')
				{
					$filter_where .= " AND abs($row->{field})=abs($filter_val) ";
				}else
				{
					$filter_where .= " AND $row->{field} = ".sql_val($filter_val);
				}
				
				}
			}
		}
	}
 
        $self->{tpl_vars}->{fields}=$proto->{fields};
        my $filter.=" $filter_where";

        my $url.="&action=filter&date=$_POST->{'date'}&currency=$_POST->{'currency'}";
##ending from oleg
	
        $self->{tpl_vars}->{trans_list}->{'do'}->{value}='trans_list';
        
        #for working with this runmode

         my $ref=
	get_transit_list(
	{color_set=>defined($_POST->{'f_id'}),color=>$_POST->{'color'},filter=>$filter,page=>$page,how=>$how}
	);
        foreach(@{$ref->{transes}})
        {
	
	        $_->{currency_f}=$_->{'currency'};
		$_->{date_f}=$_POST->{'date'};
		$_->{currency}=$conv_currency->{$_->{currency}};
		#format date
		$_->{date}=format_date($_->{date});
		
	}
		
        $self->{tpl_vars}->{transes}=$ref->{transes};
        my $paging=paging(
				{
					url=>'transit.cgi?do=trans_list'.$url,
					count_pages=>$ref->{count_pages},
					how=>$how,
					page_name=>'page',
					page=>$page
				}
			);
        
        $_POST->{currency}='UAH' if(!$avail_currency->{$_POST->{currency}}&&$_POST->{currency});
        
         $self->{tpl_vars}->{pages}=$paging->{pages};
         
 	 $self->{tpl_vars}->{title}='Список транзитов';
        
 	 $self->{tpl_vars}->{months}=\@months;
        
         map{ $self->{tpl_vars}->{$_}=$_POST->{$_} } keys %$_POST;

         my $tmpl=$self->load_tmpl('firm_transit_list.html');
 
         my $output='';
         $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
         return $output;
        

}
sub del
{
	my $self=shift;
		
	my $id1=$self->query->param('ct_id1');
	my $id2=$self->query->param('ct_id2');
	
	my $params=$dbh->selectrow_hashref(q[SELECT 
	abs(amnt) as amnt,currency,f_id1,f_id2 FROM transit_view
	WHERE ct_id1=? AND ct_id2=? AND f_id1>0 AND f_id2>0],undef,$id1,$id2);
	
	##actual problem of request's races
	unless($params->{amnt})	
	{
		$self->header_type('redirect');
		return $self->header_add(url=>'?');
	}else
	{
		
		my $res=$dbh->do(q[DELETE FROM 	firms_transit WHERE  ft_ctid1=? AND ft_ctid2=?],undef,$id1,$id2);
		
		if($res ne '1')
		{
				$self->header_type('redirect');
				return $self->header_add(-url=>'?');
	
		}
	}
	
	$_POST->{t_oid}=$self->{user_id};
	$_POST->{f_id1}=$params->{f_id2};
	$_POST->{f_id2}=$params->{f_id1};
	$_POST->{currency}=$params->{currency};
	$_POST->{amnt}=$params->{amnt};
        $_POST->{user_id}=$self->{user_id};
        $_POST->{comment}="Удаление транзита $id1$id2";
	my ($b_id1,$b_id2)=$self->add_trans_firm($_POST);
	
	#$dbh->do(qq[DELETE FROM cashier_transactions WHERE ct_status='transit' AND ct_id IN ($b_id1,$b_id2)]);
	$dbh->do(qq[DELETE FROM firms_transit WHERE ft_ctid1=$b_id1 AND  ft_ctid2=$b_id2]);

        $self->header_type('redirect');
        return $self->header_add(-url=>'transit.cgi?f_id='.$_POST->{f_id1});
	
}

sub oper_add_trans
{
        my $self=shift;
        $SIG{__DIE__}=\&handle_errors_add_trans;
        $_POST->{t_oid}=$self->{user_id};
        $_POST->{user_id}=$self->{user_id};
	    $_POST->{amnt}=~s/[ ]//g;
	    $self->add_trans_firm($_POST);
        $self->header_type('redirect');
        return $self->header_add(-url=>'transit.cgi?f_id='.$_POST->{f_id1});
}


sub handle_errors_add_trans
{
        my $msg=join ',', @_;
        print "Content-type: text/html; charset=cp1251\n\n";
        my $tmpl = Template->new(
        {
         INCLUDE_PATH => '../tmpl',
         INTERPOLATE  => 1,               # expand "$var" in plain text
         POST_CHOMP   => 1,               # cleanup whitespace 
         EVAL_PERL    => 1,       
        }
        );
        my $rights=get_rights($_POST->{user_id});
        $rights->{'index'}=1;
        $_POST->{rights}=$rights;
        my $firms=get_firms();
	
	    my $tabs=get_desc_rights();
       	foreach(@$tabs)
        {
		    if($rights->{$_->{value}})
		    {
			    $_POST->{tabs}->{$_->{value}}=$_->{title};		
		    }
		    
	    }
 		
	$_POST->{my_firms}=$firms;
    
        $_POST->{title}='Ошибка при проведение транзита ';
        $_POST->{error}=$msg;
  
        $tmpl->process('firm_add_transit_self.html',$_POST) || die $tmpl->error();
        $SIG{__DIE__}=undef;
}
1;
