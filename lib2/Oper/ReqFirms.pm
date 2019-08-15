package Oper::ReqFirms;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $proto={
  'table'=>"cashier_transactions",  
  'page_title'=>'Б/н заявки ',
  'template_prefix'=>"firm_req",
  'extra_where'=>" ct_fid>0 AND ct_req='yes'",
  'need_confirmation'=>1,
  'id_field'=>'ct_id',
  'sort'=>'ct_ts DESC',
  'fields'=>[
    {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
    {'field'=>"ct_date",category=>'date', "title"=>"Дата  ","default"=>$now_hash->{sql}
    },
   {'field'=>"ct_ts", "no_add_edit"=>1, 'filter'=>"time","add_expr"=>"NOW()", "title"=>"Дата поступления"

   },
   {'field'=>"ct_req", "no_add_edit"=>1, "add_expr"=>"'yes'", no_view=>1 },
   {'field'=>"ct_fid", "title"=>"Фирма", "category"=>"firms", "type"=>"select"
     ,'filter'=>"="
    },
    {'field'=>"ct_amnt", "title"=>"Сумма",'filter'=>"="},
    {'field'=>"ct_currency", "title"=>"Валюта"
     , "type"=>"select"
     , "titles"=>\@currencies
     ,'filter'=>"="
    },
    {
     'field'=>"ct_comment", "title"=>"Назначение", 'default'=>"Ввод безналом",
     'filter'=>'like'
    },
    {'field'=>"ct_oid", "title"=>"Оператор"
      , "no_add_edit"=>1, "category"=>"operators",add_expr=>''
    },
    #{'field'=>"ct_tid", "title"=>"Транзакция", "no_add_edit"=>1,},

    {'field'=>"ct_status", "title"=>"Статус проведения"
      ,"no_add_edit"=>1, 
      ,"no_view"=>1,
    },
  ],
};


sub setup
{
  my $self = shift;
    
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'add'  => 'add',
  );
}
sub get_right
{
                my $self=shift;

        return 'req_firms';
}
sub list
{
   my $self = shift;
   return $self->proto_list($proto);
}

sub add
{
   my $self = shift;
   my $ct_amnt=$self->query->param('ct_amnt');
   
   $ct_amnt=~s/[,]/\./;
   $ct_amnt=~s/[ \,\\]//g;
   map{ $_->{expr}=$self->{user_id} if($_->{field} eq 'ct_oid') }	@{ $proto->{fields} };

   $self->query->param('ct_amnt',$ct_amnt);
   $proto->{'page_title'}='Добавить б/н заявку ';
   return $self->proto_add_edit('add', $proto);
}


1;