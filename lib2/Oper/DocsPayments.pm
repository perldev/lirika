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

    $proto->{fields}->[3]->{titles}=&get_out_firms();
    $proto->{fields}->[4]->{titles}=&get_accounts_simple();

    $proto={
  'table'=>"documents_payments_view",  
  'template_prefix'=>"docs_paymensts",
  'page_title'=>"������ ������ �� ���������",
  'extra_where'=>q[ dr_status='created' ],
  'sort'=>'dr_ts DESC',
  'key_hashes'=>['key_field','dr_fid','dr_aid'],
  'fields'=>[
  {'field'=>"dr_date", filter=>'time'},
    {'field'=>"ct_amnt", "no_add_edit"=>1, "no_view"=>1, "title"=>"�����",},
    {
	'field'=>"dr_fid", "title"=>"�����", 'filter'=>"="
      , "type"=>"select",
      , "category"=>'firms',
    select_search=>1

    },
    {
	'field'=>"dr_ofid_from", "title"=>"C �����", 'filter'=>"="
      , "type"=>"select",
      , "category"=>'out_firms',
     select_search=>1

    },
   {
     	'field'=>"dr_aid", "title"=>"���������", "category"=>"accounts",
	'type'=>'select',
    'filter'=>'=' ,
    select_search=>1     
    },
    {'field'=>"ct_amnt", "title"=>"�����",  'filter'=>"=",'positive'=>1},
 
    {'field'=>"ct_comment", "title"=>"����������",filter=>'=' },
  ],
  formating=>{dr_date=>'month_year'}    

};


    return 'docs_pays';
}
sub setup
{
  my $self = shift;
  
  $self->run_modes(
    'AUTOLOAD'   => 'list',
  );
}


sub list
{
	my $self = shift;
	return $self->proto_list($proto);
	
}
1;