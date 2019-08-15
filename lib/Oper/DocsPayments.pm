package Oper::DocsPayments;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
use Documents;
my $proto;
sub get_right
{       
    my $self=shift;


 

    $proto={
  'table'=>"documents_payments_view",  
  'template_prefix'=>"docs_paymensts",
  'page_title'=>"Правки оплаты по документы",
  'extra_where'=>q[ dr_status='created' ],
  'sort'=>'dr_ts DESC',
  'key_hashes'=>['key_field','dr_fid','dr_aid'],
  'fields'=>[
  {'field'=>"dr_date", filter=>'time'},
    {
	'field'=>"dr_fid", "title"=>"Фирма", 'filter'=>"eq"
      , "type"=>"select",
      , "category"=>'firms',
     select_search=>1

    },
#     {
# 	'field'=>"dr_ofid_from", "title"=>"C фирма", 'filter'=>"="
#       , "type"=>"select",
#       , "category"=>'out_firms',
#      select_search=>1
# 
#     },
   {
     	'field'=>"dr_aid", "title"=>"Программа",
	'type'=>'select',
    'filter'=>'=' ,
    select_search=>1     
    },
    {'field'=>"ct_amnt", "title"=>"Сумма",  'filter'=>"eq",'positive'=>1},
 
    {'field'=>"ct_comment", "title"=>"Назначение",filter=>'=' },
  ],
  formating=>{dr_date=>'month_year'}    

};
#   $proto->{fields}->[2]->{titles}=&get_out_firms();
    $proto->{fields}->[2]->{titles}=&get_accounts_simple();



    return 'docs_pays';
}
sub setup
{
  my $self = shift;
  $self->start_mode('list');
  $self->run_modes(
    'AUTOLOAD'   => 'list',
  );
}


sub list{
	my $self = shift;


	return $self->proto_list($proto);
	
}
1;
