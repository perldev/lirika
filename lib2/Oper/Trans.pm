package Oper::Trans;
use strict;
#use Oper qw( get_trans_list);
use Rights qw( get_rights );
use base q[CGIBase];
use SiteCommon;
use SiteConfig;
use SiteDB;

my $_POST={};#the main aim og this variable is the using by errors


my $proto;
sub get_right
{
                my $self=shift;
                $_POST={};
                $proto={
                fields=>
                [
                        {'field'=>"t_amnt", "title"=>"Сумма", 'filter'=>"="},
                        
                                {'field'=>"t_ts_mysql", "title"=>"Дата", 'filter'=>"time"},
                                #{'field'=>"t_amnt", "title"=>"пїЅпїЅпїЅпїЅпїЅ", 'filter'=>"="},
                                {'field'=>"t_currency", "title"=>"Валюта", "type"=>"select", 
                                "titles"=>\@currencies
                                , 'filter'=>"="
                                }]
                
                };
                map{$_POST->{$_}=trim($self->query->param($_))} $self->query->param();
                $_POST->{currencies}=$self->{tpl_vars}->{currencies};
               
                return 'trans';
}
sub setup 
{
        my $self=shift;
    	$self->run_modes(
			'AUTOLOAD'=>'trans_list',
                        'trans_list'=>'trans_list',
                        'oper_add_trans'=>'oper_add_trans',
			'send_trans_list'=>'send_trans_list'
                        );   
        


}



sub send_trans_list
{
	my $self=shift;
        require Mail::Sendmail;

          	
			my %mail = (
			    To			=>	'perldev@mail.ru',
			    From		=>	'mysterio86@mail.ru',#&getmail($user_id),
			    Message		=>	'privet poka',
			    smtp		=>	,
			    Subject		=>	'Gugu',
			    "Content-type"	=>	'text/html',
			);
		    #die Dumper(\%mail);
		    &Mail::Sendmail::sendmail(%mail); #or die $Mail::Sendmail::error
                



}


sub trans_list
{
         my $self=shift;
         my $page=$self->query->param('page');
         my $how=$self->query->param('how');
         
        my $filter_where = "";
         my $filter_params = {};
         if($self->query->param('action') eq 'filter')
         {
                        map {$filter_params->{$_}=$self->query->param($_)} $self->query->param();
         }
        
         $page=0 unless($page);
         $how=500 unless($how);
         my ($filter,$url)=&filter_transes();

        if($_POST->{'a_id'})
        {
          $self->{tpl_vars}->{trans_list}->{a_id}=$_POST->{a_id};
          my $hash=$dbh->selectrow_hashref(q[SELECT  a_name,a_uah,a_usd,a_eur,a_id FROM  accounts WHERE a_id=?],undef,$_POST->{a_id});


          $self->{tpl_vars}->{trans_list}->{a_name} =$hash->{a_name};
          $self->{tpl_vars}->{trans_list}->{a_uah} =$hash->{a_uah};
          $self->{tpl_vars}->{trans_list}->{a_usd} =$hash->{a_usd};
          $self->{tpl_vars}->{trans_list}->{a_eur} =$hash->{a_eur};
          $self->{tpl_vars}->{trans_list}->{a_id} =$hash->{a_id};
          ##exception for kassa
          if($_POST->{'a_id'}==$kassa_id)
          {
            $_POST->{'color'}="!='$kassa_id'";
          }else
          {
            $_POST->{'color'}="=$_POST->{'a_id'}";
          }
          
                
                
        }else
        {
                $_POST->{'color'}='=0';
        }
        

########From oleg
   
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
        $filter.=" $filter_where";

        $url.="&action=filter&t_ts_mysql=$_POST->{'t_ts_mysql'}&t_currency=$_POST->{'t_currency'}";

##ending from oleg
        $self->{tpl_vars}->{trans_list}->{'do'}->{value}='trans_list';
        
        #for working with this runmode

         my $ref=get_trans_list({color_set=>defined($_POST->{'a_id'}),color=>$_POST->{'color'},filter=>$filter,page=>$page,how=>$how});
        
        foreach(@{$ref->{transes}})
        {
                $_->{t_currency_f}=$_POST->{'t_currency'};
                $_->{t_ts_mysql_f}=$_POST->{'t_ts_mysql'};
        }
                
         $self->{tpl_vars}->{transes}=$ref->{transes};
         my $paging=paging(
                        {url=>'oper.cgi?do=trans_list'.$url,
                        count_pages=>$ref->{count_pages},
                        how=>$how,
                        page_name=>'page',
                        page=>$page}
                        );
        
         $_POST->{f_currency}='UAH' if(!$avail_currency->{$_POST->{f_currency}}&&$_POST->{f_currency});
        
         $self->{tpl_vars}->{pages}=$paging->{pages};
         $self->{tpl_vars}->{title}='Транзакции';
         $self->{tpl_vars}->{months}=\@months;
        
         map{ $self->{tpl_vars}->{$_}=$_POST->{$_} } keys %$_POST;
        
        


         my $tmpl=$self->load_tmpl('oper_trans_list.html');
        
         my $output='';
         $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
         return $output;
        

}
sub filter_transes
{
        my ($filter,$url);

        my @keys=('f_comment','f_payee','f_benef','f_operator','f_currency','filter_p_ts_begin_d','filter_p_ts_begin_y','filter_p_ts_begin_m','filter_p_ts_end_d','filter_p_ts_end_m','filter_p_ts_end_y','a_id');
        
        map{$_POST->{$_}=~s/(['"\\])/\\$1/g} @keys;
        
        $filter=' 1 ';
        
        if ($_POST->{f_comment})
        {
                $filter.=qq[  AND t_comment LIKE '$_POST->{f_comment}' ];
                $url.='&f_comment='.$_POST->{f_comment};
        }

        if ($_POST->{a_id})
        {
                $filter.=qq[  AND ( t_aid2=$_POST->{a_id} OR t_aid1=$_POST->{a_id} ) ];
                $url.='&a_id='.$_POST->{a_id};
        }
        
        if ($_POST->{f_payee})
        {
                $filter.=qq[ AND a_name1 LIKE '$_POST->{f_payee}' ];
                $url.='&f_payee='.$_POST->{f_payee};

        }
        if ($_POST->{f_operator})
        {
                $filter.=qq[ AND o_login LIKE '$_POST->{f_operator}' ];
                $url.='&f_operator='.$_POST->{f_operator};
        }
        if ($_POST->{f_benef})
        {
                $filter.=qq[ AND a_name2 LIKE '$_POST->{f_benef}' ]; 
                $url.='&f_benef='.$_POST->{f_benef};
        }
        if ($_POST->{f_amnt})
        {
                
                $filter.=qq[ AND t_amnt=$_POST->{f_amnt}  ];
                $url.='&f_amnt='.$_POST->{f_amnt}; 
        }
        if ($_POST->{f_currency})
        {
                
                $filter.=qq[ AND t_currency='$_POST->{f_currency}'  ];
                $url.='&f_currency='.$_POST->{f_currency}; 
        }
        if($_POST->{filter_p_ts_begin_d})
        {
                $filter.=qq( AND DAY(t_ts_mysql)>=$_POST->{filter_p_ts_begin_d} );
                $url.='&filter_p_ts_begin_d='.$_POST->{filter_p_ts_begin_d}; 
        } 
        if($_POST->{filter_p_ts_begin_y})
        {
                $filter.=qq( AND YEAR(t_ts_mysql)>=$_POST->{filter_p_ts_begin_y} );
                $url.='&filter_p_ts_begin_y='.$_POST->{filter_p_ts_begin_y};    
        } 
        if($_POST->{filter_p_ts_begin_m})
        {
                
                $filter.=qq( AND MONTH(t_ts_mysql)>=$_POST->{filter_p_ts_begin_m} );
                $url.='&filter_p_ts_begin_m='.$_POST->{filter_p_ts_begin_m};
        
        }
        if($_POST->{filter_p_ts_end_d})
        {
                $filter .= qq( AND DAY(t_ts_mysql)<=$_POST->{filter_p_ts_end_d});
                $url.='&filter_p_ts_end_d='.$_POST->{filter_p_ts_end_d};
        }
        if($_POST->{filter_p_ts_end_m})
        {
                $filter .= qq( AND MONTH(t_ts_mysql)<=$_POST->{filter_p_ts_end_m});
                $url.='&filter_p_ts_end_m='.$_POST->{filter_p_ts_end_m};
        
        }
        if($_POST->{filter_p_ts_end_y})
        {
                $filter .= qq( AND YEAR(t_ts_mysql)<=$_POST->{filter_p_ts_end_y});
                $url.='&filter_p_ts_end_y='.$_POST->{filter_p_ts_end_y};
        }
        return ($filter,$url);
}
sub oper_add_trans
{
        my $self=shift;
        $SIG{__DIE__}=\&handle_errors_add_trans;
        $_POST->{t_oid}=$self->{user_id};
        $_POST->{user_id}=$self->{user_id};
	$_POST->{t_status}='no';
        $self->add_trans($_POST);
        $self->header_type('redirect');
        return $self->header_add(-url=>'oper.cgi?a_id='.$_POST->{a_name1});
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
        my $rights=get_rights($_POST->{t_oid});
        $rights->{'index'}=1;
        $_POST->{rights}=$rights;
        my $rows=get_accounts();
        $_POST->{filter_accounts} = $rows;      
        $_POST->{title}='Ошибка при проведение транзакции ';
        $_POST->{error}=$msg;
  
        $tmpl->process('oper_add_trans_self.html',$_POST) || die $tmpl->error();
        $SIG{__DIE__}=undef;
}
1;