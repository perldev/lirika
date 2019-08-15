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
        'page_title'=>'�������',
        
        'fields'=>[
            {'field'=>"cl_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
            {'field'=>"cl_cid", "title"=>"������", 'filter'=>"="},    
            {'field'=>"cl_ts", "title"=>"����" },
            {'field'=>"cl_amnt", "title"=>"������"},
            {'field'=>"cl_percent", "title"=>"�������"},
            {'field'=>"cl_penalty", "title"=>"���� �� ����"},
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