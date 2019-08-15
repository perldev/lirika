package Oper::CreditLogs;

use strict;

use base 'CGIBase';

use SiteConfig;
use SiteDB;
use SiteCommon;
my $proto;
sub get_right
{       
        my $self=shift;

        $proto={
        'table'=>"credit_logs",    
        'page_title'=>'Кредиты',
        
        'fields'=>[
            {'field'=>"cl_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
            {'field'=>"cl_cid", "title"=>"Кредит", 'filter'=>"="},    
            {'field'=>"cl_ts", "title"=>"Дата" },
            {'field'=>"cl_amnt", "title"=>"Баланс"},
            {'field'=>"cl_percent", "title"=>"Процент"},
            {'field'=>"cl_penalty", "title"=>"Пеня за день"},
        ],
        };
       return 'credit';
}


sub setup
{
  my $self = shift;
    
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
  );
}


sub list
{
   my $self = shift;
   return $self->proto_list($proto);
}

sub add
{
   my $self = shift;
   return $self->proto_add_edit('add', $proto);
}

sub edit
{
   my $self = shift;
   return $self->proto_add_edit('edit', $proto);
}



sub del
{
   my $self = shift;
   return $self->proto_action('del', $proto);
}






1;