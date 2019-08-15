package Oper::FactDocs;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $proto;
sub get_right{       
    my $self=shift;

 $proto={
    'table'=>"documents_transactions_okpo",  
    'template_prefix'=>"docs_transactions",
    'need_confirmation'=>0,
    'extra_where'=>"dt_status!='canceled' ",
    'page_title'=>"Документы по фирмам",
    'sort'=>'dt_date DESC',
    'fields'=>[
        {
        'field'=>"dt_oid", "title"=>"Оператор", "category"=>"operators",
    
        },
    
        {'field'=>"dt_date", "no_add_edit"=>1, "no_view"=>1, "title"=>"Дата",},
            {'field'=>"dt_date", "title"=>"Дата",  'category'=>"date",'filter'=>"time",},
    
    
        {
	    'field'=>"dt_fid", "title"=>"Фирма", 'filter'=>"="
        , "type"=>"select",
        , "category"=>'firms'
        ,select_search=>1
        },
    {'field'=>"dt_okpo", "title"=>"ОКПО",filter=>'='},
    {
            'field'=>"dt_ofid", "title"=>"Покупатель", 'filter'=>"="
        , "type"=>"select",
        , "category"=>'out_firms',
            select_search=>1
    
    },
    {
        'field'=>"dt_aid", "title"=>"Программа", "category"=>"accounts",
	    'type'=>'select',
	    
	    'filter'=>'='
        ,select_search=>1 
        },
    
        {'field'=>"dt_amnt", "title"=>"Сумма",  'filter'=>"=",'positive'=>1},
    
        {'field'=>'dt_ts',category=>'date'},
    
        {'field'=>"dt_currency", "title"=>"Валюта", 
	    'titles'=>\@currencies,
	    'type'=>'select'
        },
    
    ],
        formating=>{dt_date=>'month_year'}    
    };
    
    $proto->{fields}->[6]->{'titles'}=&get_accounts_simple($CLIENT_CATEGORY);


    return 'docs_fact';
}

sub setup
{
  my $self = shift;
  
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'add'=>'add',
    'edit'=>'edit',
    'del'=>'del',

  );
}




sub list
{
	my $self = shift;
    	$self->{tpl_vars}->{accounts}=&get_accounts_simple($CLIENT_CATEGORY);
	return $self->proto_list($proto);
	
}





1;