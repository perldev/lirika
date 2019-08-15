package Oper::Credits;

use strict;

use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $proto;
sub get_right{       
  my $self=shift;

    
  $proto={
  'table'=>"credits",    
  'extra_where'=>"c_finish IS NULL",
  'extra_where2'=>"c_finish IS NOT NULL", #for second table (@rows2)
  'page_title'=>'Активные кредиты', 
  'need_confirmation'=>1,

  'fields'=>[
    {'field'=>"c_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID

    {'field'=>"c_start","category"=>"date",'type'=>'date',"title"=>"Дата начала", "default"=>$now_hash->{sql} },
    {'field'=>"c_planned_finish",'type'=>'date',"title"=>"Дата планируемого окончания", "default"=>$now_hash->{sql},category=>'date'},
    
    {'field'=>"c_aid", "title"=>"Карточка", "category"=>"accounts"},    

    {'field'=>"c_amnt", "title"=>"Сумма", 'filter'=>"="
     , "positive"=>1
    },

    {'field'=>"c_currency", "title"=>"Валюта", 'filter'=>"="
     , "type"=>"select"
     , "titles"=>\@currencies
    },

    {'field'=>"c_percent", "title"=>"Процент", 'filter'=>"="
     , "positive"=>1, "default"=>5
    },

    {'field'=>"c_free_days", "title"=>"Бесплатных дней", 'filter'=>"="
     , "default"=>1
    },

    
    {'field'=>"c_comment", "title"=>"Назначение",},

    {'field'=>"c_oid", "title"=>"Оператор"
      , "no_add_edit"=>1, "category"=>"operators"
    },
    {'field'=>"c_tid", "title"=>"Транзакция", "no_add_edit"=>1,},


    {'field'=>"c_oid2", "title"=>"Оператор 2"
      , "no_add_edit"=>1, "category"=>"operators"
    },




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
    'add'  => 'add',
    'edit' => 'edit',
    'del'  => 'del',
    'credit_process' => 'credit_process',
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
  $proto->{page_title}='Новый кредит';

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
   my $id=$self->query->param('id');
   my $ref=$dbh->selectrow_hashref(q[SELECT c_tid FROM credits WHERE c_id=?],undef,$id);
   return $self->error('Не могу найти транзакцию ')  unless($ref->{c_tid});
   require  Oper::Ajax;
   $self->query->param('id',$ref->{c_tid});
   Oper::Ajax::delete_transfer_by_transaction($self);
    $dbh->do(q[DELETE FROM credits WHERE c_id=?],undef,$id);
    $self->header_type('redirect');
    return $self->header_add(-url=>"?");

}


sub credit_process{
  my $self = shift;

  my $id = $self->query->param('id');


       my $credit = $dbh->selectrow_hashref(
           "SELECT * 
           , DATEDIFF(now(), c_start) as pass_days
           FROM credits WHERE c_id=?
           AND c_planned_finish IS NOT NULL AND c_finish IS NULL" #not completed MANUAL credit
           , undef, $id
       );
       if($credit){
         my $aid = $credit->{c_aid};
         my $cur = $credit->{c_currency};

         my $cid = $credit->{c_id};
         #my $penalty = process_penalty($credit, $credit->{c_amnt}, $sum);

             my $csum = $credit->{c_amnt} + $credit->{c_amnt2}; #credit sum with penalty
             

             my $tid = $self->add_trans(
               {    
                 t_name1 => $aid,
                 t_name2 => $credit_id,
                 t_currency => $cur,
                 t_amnt => $csum,
                 t_comment => "Возвращение кредита (ручное), $credit->{c_comment}",
               }
             );

             $dbh->do("UPDATE credits SET c_finish=NOW(), c_tid2=?, c_oid2=? WHERE c_id=?"
               , undef, $tid, $self->{user_id}, $cid
             );
       }


  return $self->header_add(-location=>"?");
}


sub proto_add_edit_trigger{
  my $self=shift;
  my $params = shift;    

  if($params->{step} eq 'before'){


   my $aid = $self->query->param('c_aid');
   my $amnt = $self->query->param('c_amnt');
   my $currency = $self->query->param('c_currency');
   my $percent = $self->query->param('c_percent');
   my $comment = $self->query->param('c_comment');
   my $start  = $self->query->param('c_start');
   my $finish = $self->query->param('c_planned_finish');
   my $free_days = $self->query->param('c_free_days');

   $comment = "Кредит $amnt $currency под $percent\% ($free_days дней бесплатно) c $start по $finish, $comment";

   my $tid = $self->add_trans({
      t_name1 => $credit_id,
      t_name2 => $aid,
      t_currency => $currency,
      t_amnt => $amnt,
      t_comment => $comment,
   });

   foreach my $row( @{$params->{proto}->{fields}} ){
     if($row->{field} eq 'c_oid'){
       $row->{expr} = $self->{user_id}
     }elsif($row->{field} eq 'c_tid'){
       $row->{expr} = $tid;
     }
   }
   return 1;


   

  }elsif($params->{step} eq 'operation'){
    $dbh->do($params->{sql});
  }

}

1;