package Oper::ExchangeOdessa;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use Rights qw( get_rights );
use SiteCommon;
my $RIGHT='exch_odessa';
my $_POST={};
my $proto;
sub get_right
{
        my $self=shift;
        $self->{exchange_card}=-35;
        $proto={
            'page_title'=>'Обмены Одесса',	
            'exchange_card'=>$self->{exchange_card},
            'extra_where'=>" AND a_id=".$self->{exchange_card},  #AND ct_status='created'
            fields=>
            [
		                
                            
                            {'field'=>"e_id", 'filter'=>"=",'filter_invisible'=>'1'},
                            {'field'=>"e_date", "title"=>"Дата ", 'filter'=>"time"},
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
        map{$_POST->{$_}=trim($self->query->param($_))} $self->query->param();
        $_POST->{currencies}=$self->{tpl_vars}->{currencies};
        return $RIGHT;
}

sub setup 
{
        my $self=shift;
     
	    $self->start_mode('list');
        $self->run_modes(
                        
                        'AUTOLOAD' =>     'list',
                        'list'  =>     'list',
                        'add'	=>'add',
        );      



}

sub list
{
         my $self=shift;
         my $page=$self->query->param('page');
         my $how=$self->query->param('how');
         
         my $filter = "  1 ".$proto->{extra_where};
         my $filter_params = {};
         if($self->query->param('action') eq 'filter')
         {
                        map {$filter_params->{$_}=$self->query->param($_)} $self->query->param();
         }
        
         $page=0 unless($page);
         $how=500 unless($how);
      
        

########From oleg must  be excluded to the one function!!
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
        require Oper::Exchange;
        my $ref=Oper::Exchange::exc_list({filter=>$filter,page=>$page,how=>$how});##get  exchanges list
        
        
#filling rates javascript
        my ($rate_cash,$rate_cash_less)=get_rates();
        $self->{tpl_vars}->{rate_cash}=$rate_cash;
        $self->{tpl_vars}->{rate_cash_less}=$rate_cash_less;
##


         $self->{tpl_vars}->{list}=$ref->{list};
         my $paging=paging(
                                {
                                        url=>'exch_odessa.cgi?do=list'.$url,
                                        count_pages=>$ref->{count_pages},
                                        how=>$how,
                                        page_name=>'page',
                                        page=>$page
                                }
                        );
        
         $_POST->{f_currency}='UAH' if(!$avail_currency->{$_POST->{f_currency}}&&$_POST->{f_currency});

         $self->{tpl_vars}->{pages}=$paging->{pages};
         $self->{tpl_vars}->{page_title}=$proto->{page_title};
         $self->{tpl_vars}->{proto_params}=$proto;

         
         map{ $self->{tpl_vars}->{$_}=$_POST->{$_} } keys %$_POST;
        
         my $tmpl=$self->load_tmpl('exchange_list.html');
         my $output='';
         $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
         return $output;

}
sub add
{
        my $self=shift;
        $_POST->{t_oid}=$self->{user_id};
        $_POST->{user_id}=$self->{user_id};
     
	    $SIG{__DIE__}=\&handle_errors_add_exc;
     	$_POST->{a_id}=$self->{exchange_card};
        die "Выберите разные валюты пожайлуста\n" if($_POST->{e_currency1} eq $_POST->{e_currency2});
        ###for cashbox  because there is the invert balance on its
        $_POST->{e_amnt1}*=-1;
        ###
        $self->add_exc($_POST);
        $self->header_type('redirect');
        return $self->header_add(-url=>'exch_odessa.cgi?do=list');


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
        $_POST->{title}='Ошибка при проведение обмена ';
        $_POST->{error}=$msg;
        $_POST->{display}=1;
        my ($rate_cash,$rate_cash_less)=get_rates();
        $_POST->{rate_cash}=$rate_cash;
        $_POST->{proto_params}=$proto;
        $_POST->{rate_cash_less}=$rate_cash_less;  
        $tmpl->process('exchange_add_self.html',$_POST) || die $tmpl->error();
        $SIG{__DIE__}=undef;
}





1;
