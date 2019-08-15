package Oper::Firms;

use strict;

use base 'CGIBaseOut';

use SiteConfig;
use SiteDB;
use SiteCommon;

my $firm_services = undef;
unless($firm_services){
  $firm_services = [];

   my $sth =$dbh->prepare(qq[SELECT * FROM firm_services
     WHERE fs_id>0 AND fs_status='active'
     ORDER BY fs_id
   ]);

   $sth->execute();                          
   while(my $r = $sth->fetchrow_hashref)
   {
     push @$firm_services, {
       'value'=>$r->{fs_id}, 'title'=>$r->{fs_name}
     };
   }
   $sth->finish();
}

my $proto={
  'table'=>"firms_out_operators",  
  'template_prefix'=>"firms",

  'page_title'=>'Фирмы',
  'sort'=>'f_name ',
  'fields'=>[
    {'field'=>"f_id", "title"=>"ID", "no_add_edit"=>1,filter=>'='}, #first field is ID
    {'field'=>"f_ts", "no_add_edit"=>1, "add_expr"=>"NOW()", "title"=>"Дата"},
    {'field'=>"f_name", "title"=>"Название",filter=>'like'},
   
    {'field'=>"f_phones", "title"=>"Телефоны"},
    {'field'=>"f_status", "type"=>"select", "del_value"=>"deleted",
      "titles"=>[
        {'value'=>"active", 'title'=>"активен"},
        {'value'=>"blocked", 'title'=>"заблокирован"},
      ]
      , "title"=>"Cтатус"
    },
    {'field'=>"f_services", "title"=>"Услуги", 
      'type'=>"set", "titles"=>$firm_services},
    {'field'=>"f_percent", "title"=>"Процент за приход (ГРН)",
    'default'=>0},
    {'field'=>"f_uah", "no_add_edit"=>1, "title"=>"Баланс, гривна"},
    {'field'=>"f_usd", "no_add_edit"=>1, "title"=>"Бланс, доллар"},
    {'field'=>"f_eur", "no_add_edit"=>1, "title"=>"Баланс, евро"},
  ],
};

sub setup
{

  my $self = shift;
  $self->start_mode('list');
   $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
  );

}
sub get_right
{
        my $self=shift;
       return 'firm';
}
sub list
{
   my $self = shift;
   
   $proto->{extra_where}=' o_id='.$self->{user_id};
   return $self->proto_list($proto);
}
1;
