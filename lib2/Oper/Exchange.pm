package Oper::Exchange;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use Rights qw( get_rights );
use SiteCommon;
my $RIGHT='exchange';
my $_POST={};
my $proto;
sub get_right
{
        my $self=shift;
 
$proto={
    'page_title'=>'Обмены',	
    fields=>
    [
		    
                            
                    {'field'=>"e_id", 'filter'=>"=",'filter_invisible'=>'1'},
                    {
                    'field'=>"a_id",
                    'filter'=>"=",
                    title=>'Программа',
                    'type'=>'select',
                    },
    
                    {'field'=>"e_date", "title"=>"Дата ", 'filter'=>"time"},
    #                  {'field'=>"t_ts1", "title"=>"Дата заведения", 'filter'=>"time"},
    
                    #{'field'=>"t_amnt", "title"=>"Сумма", 'filter'=>"="},
                    {'field'=>"e_currency1", "title"=>"Из валюты", "type"=>"select"
                    , "titles"=>\@currencies
                    , 'filter'=>"="
                    },
                    {'field'=>"e_currency2", "title"=>"В валюту", "type"=>"select"
                    , "titles"=>\@currencies
                    , 'filter'=>"="
                    }
    ]
    };
       $proto->{fields}->[1]->{titles}=get_accounts_simple();
        map{$_POST->{$_}=trim($self->query->param($_))} $self->query->param();
        $_POST->{currencies}=$self->{tpl_vars}->{currencies};
        return 'exchange';
}

sub setup 
{
        my $self=shift;
     

        $self->run_modes(
                        
                        'AUTOLOAD' =>     'list',
                        'list'  =>     'list',
                        'add'	=>'add',
                        'back'	=>'back'
        );      



}

###such methods may be done as ajax!!
###done through ajax
sub back
{
	my $self=shift;
	my $id=$self->query->param('id');
	
### fixed
##such alorithm used in order to avoid races
	my $mutex=$dbh->do(q[UPDATE exchange SET e_status='deleted' 
	WHERE e_status='processed' AND
	  e_type!='auto' AND e_id=?],undef,$id);
	if($mutex ne '1')
	{
		$self->header_type('redirect');
      		 return $self->header_add(-url=>'exc.cgi?do=list');
	}

 	#e_status='deleted'

	my $ref=$dbh->selectrow_hashref(q[SELECT * FROM exchange_view 
    	WHERE e_status='deleted' AND 
	      e_type!='auto' AND e_id=?],undef,$id);

			$ref->{e_rate}=pow($ref->{e_rate},-1) if($ref->{e_currency2} eq $ref->{e_currency1});

			my $ct_eid=$self->add_exc(
			{
			
				type=>$ref->{e_type},
				rate=>pow($ref->{e_rate},$RATE_FORMS{$ref->{e_currency1}}->{$ref->{e_currency2}}),
				e_comment=>qq[Откат бмена для  #$ref->{e_id}],
				e_currency1=>$ref->{e_currency2},
				e_currency2=>$ref->{e_currency1},
				e_amnt1=>$ref->{e_amnt2},
				a_id=>$ref->{a_id},
			}
				);

	$dbh->do(q[UPDATE exchange 
			  SET e_status='deleted' WHERE e_id=?
			],undef,$ct_eid);

	my($back_1,$back_2)=$dbh->selectrow_array(q[SELECT e_tid1,e_tid2
	 FROM exchange WHERE e_id=?],undef,$ct_eid);

	$dbh->do(q[
		UPDATE 	exchange SET 
		e_back_tid1=?,e_back_tid2=? 
		WHERE e_id=?
	],undef,$back_1,$back_2,$id);

 	$self->header_type('redirect');
      	 return $self->header_add(-url=>'exc.cgi?do=list');

}
sub list
{
         my $self=shift;
         my $page=$self->query->param('page');
         my $how=$self->query->param('how');
         
         my $filter = "  1 ";
         my $filter_params = {};
         if($self->query->param('action') eq 'filter')
         {
                        map {$filter_params->{$_}=$self->query->param($_)} $self->query->param();
         }
        
         $page=0 unless($page);
         $how=500 unless($how);
      
        

########From oleg
   my $filter_where='';

   foreach my $row( @{$proto->{fields}} ){
     if($row->{type} eq 'select'){
      my %select=();
      foreach my $option( @{$row->{titles}} ){
       $select{ $option->{value} } = $option->{title};
      }

      $row->{ "titles_hash" } = \%select;     
     }

        if(defined $row->{filter}){
                my $filter_val = "".$filter_params->{ $row->{field} };
                my $filter_val_empty = length($filter_val)==0;

       if($row->{filter} eq 'time' && $filter_val_empty){
         $filter_val = "today";
         $filter_val_empty = 0;         
       }

       #die "$row->{filter} - '$filter_val' - $filter_val_empty";

       if(!$filter_val_empty){
         $row->{value}=$filter_val;

         if($row->{filter} eq 'time'){
           my $res = time_filter($filter_val);
           $filter_where .= " AND '$res->{start}'<=$row->{field} AND '$res->{end}'>=$row->{field}";
         }elsif($row->{filter} eq 'like'){
           $filter_where .= " AND lcase($row->{field}) like lcase(".sql_val($filter_val.'%').")";
           
         }else{
           $filter_where .= " AND $row->{field} = ".sql_val($filter_val);
           
         }
       }
     }
   }
                
     
     
        $self->{tpl_vars}->{fields}=$proto->{fields};
           $filter.=$filter_where;
	
        my $url="&action=filter&t_ts1=$_POST->{'t_ts1'}&e_currency1=$_POST->{'e_currency1'}&e_currency2=$_POST->{'e_currency2'}";

        ##ending from oleg


        $self->{tpl_vars}->{trans_list}->{'do'}->{value}='list';
        $self->{tpl_vars}->{a_id}=$filter_params->{a_id};
    #for working with this runmode
         my $ref=exc_list({filter=>$filter,page=>$page,how=>$how});##get  exchanges list
        
        
#filling rates javascript
        my ($rate_cash,$rate_cash_less)=get_rates();
        $self->{tpl_vars}->{rate_cash}=$rate_cash;
        $self->{tpl_vars}->{rate_cash_less}=$rate_cash_less;
##


         $self->{tpl_vars}->{list}=$ref->{list};
         my $paging=paging(
                                {
                                        url=>'exc.cgi?do=list'.$url,
                                        count_pages=>$ref->{count_pages},
                                        how=>$how,
                                        page_name=>'page',
                                        page=>$page
                                }
                        );
        
         $_POST->{f_currency}='UAH' if(!$avail_currency->{$_POST->{f_currency}}&&$_POST->{f_currency});
        

         $self->{tpl_vars}->{pages}=$paging->{pages};
         $self->{tpl_vars}->{page_title}=$proto->{page_title};

         $self->{tpl_vars}->{title}='Обмен валют';
         
         map{ $self->{tpl_vars}->{$_}=$_POST->{$_} } keys %$_POST;
        
         my $tmpl=$self->load_tmpl('exchange_list.html');
         my $output='';
         $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
         return $output;

}

sub exc_list
{
        my $ref=shift;
        #my ($filter,$page,$how)=@_;
        
        $ref->{page}=$ref->{page}*$ref->{how};
        my $sth=$dbh->prepare(qq[
        SELECT 
        SQL_CALC_FOUND_ROWS 
        *
        FROM exchange_view   WHERE   $ref->{'filter'}  AND e_type not in ('auto','system')  AND e_status!='deleted' ORDER BY e_date DESC LIMIT].qq[ $ref->{'page'},$ref->{'how'}]);
         

        my %types=('cash'=>'нал.','cashless'=>'безнал.');
        my @res;
        $sth->execute();
        while(my $s=$sth->fetchrow_hashref())
        {

		$s->{e_rate}=pow($s->{e_rate},$RATE_FORMS{$s->{e_currency1}}->{$s->{e_currency2}});
		$s->{e_rate}=POSIX::floor( $s->{'e_rate'}*10000)/10000;
                $s->{e_type}=$types{$s->{e_type}};
		$s->{e_date}=format_date($s->{e_date});
                push @res,$s;
        }
        
        $sth->finish();
        return {list=>\@res,count_pages=>$dbh->selectrow_array(q[SELECT found_rows()])};

}
sub add
{
        my $self=shift;
         $_POST->{t_oid}=$self->{user_id};
        $_POST->{user_id}=$self->{user_id};
        #use Data::Dumper;      
        #die Dumper $_POST;
        
	
	
         $SIG{__DIE__}=\&handle_errors_add_exc;

       	$_POST->{a_id}=$self->query->param('a_id_from');
	die "choose variouse currencies please \n" if($_POST->{e_currency1} eq $_POST->{e_currency2});
        
	  
	    $self->add_exc($_POST);
         $self->add_exc($_POST) if($_POST->{e_amnt1}=$_POST->{e_amnt3});    
         $self->add_exc($_POST) if($_POST->{e_amnt1}=$_POST->{e_amnt5});    
         $self->add_exc($_POST) if($_POST->{e_amnt1}=$_POST->{e_amnt7});    
         $self->add_exc($_POST) if($_POST->{e_amnt1}=$_POST->{e_amnt9});    
         $self->add_exc($_POST) if($_POST->{e_amnt1}=$_POST->{e_amnt11});    
         $self->add_exc($_POST) if($_POST->{e_amnt1}=$_POST->{e_amnt13});    
         $self->add_exc($_POST) if($_POST->{e_amnt1}=$_POST->{e_amnt15});    
         $self->add_exc($_POST) if($_POST->{e_amnt1}=$_POST->{e_amnt17});    
         $self->add_exc($_POST) if($_POST->{e_amnt1}=$_POST->{e_amnt19}); 
         $self->add_exc($_POST) if($_POST->{e_amnt1}=$_POST->{e_amnt21});
         $self->add_exc($_POST) if($_POST->{e_amnt1}=$_POST->{e_amnt23});
     

        $self->header_type('redirect');
        return $self->header_add(-url=>'exc.cgi?do=list');


}

sub handle_errors_add_exc
{

         my $msg=join ',', @_;
       
         print "Content-type: text/html; charset=cp1251\n\n";
        $msg=~s/at \.\.(.+)//;

        my $tmpl = Template->new(
        {
         INCLUDE_PATH => '../tmpl',
         INTERPOLATE  => 1,               # expand "$var" in plain text
         POST_CHOMP   => 1,               # cleanup whitespace 
         EVAL_PERL    => 1,       
        }
        );
   
        my $rights=get_rights($_POST->{t_oid});
        $rights->{'index'}=1;
          
        $_POST->{rights}=$rights;
        my $rows=get_accounts();
        $_POST->{filter_accounts} = $rows;      
        $_POST->{title}='Ошибка при проведение обмена ';
        $_POST->{error}=$msg;
        $_POST->{display}=1;
        my ($rate_cash,$rate_cash_less)=get_rates();
        $_POST->{rate_cash}=$rate_cash;
        $_POST->{rate_cash_less}=$rate_cash_less;  
        $tmpl->process('exchange_add_self.html',$_POST) || die $tmpl->error();

        $SIG{__DIE__}=undef;

        
        
        
}





1;