package Oper::Firms;

use strict;

use base 'CGIBase';

use SiteConfig;
use SiteDB;
use SiteCommon;

my $proto;
sub get_right
{
        my $self=shift;
        my $firm_services = undef;
        unless($firm_services){
        $firm_services = [];
        
            my $sth =$dbh->prepare(qq[SELECT * FROM firm_services
                WHERE fs_id>0 AND fs_status='active'
                ORDER BY fs_id
            ]);
            
            $sth->execute();                          
            while(my $r = $sth->fetchrow_hashref){
                push @$firm_services, {
                'value'=>$r->{fs_id}, 'title'=>$r->{fs_name}
                };
            }
            $sth->finish();
        }
        my $banks = [];
        
        my $sth =$dbh->prepare(qq[SELECT * FROM banks
            WHERE 1
            ORDER BY b_name
        ]);
        
        $sth->execute();                          
        while(my $r = $sth->fetchrow_hashref){
            push @$banks, {
            'value'=>$r->{fs_id}, 'title'=>$r->{fs_name}
            };
        }
        $sth->finish();
        

    
 $proto={
  'table'=>"firms",  
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
    {'field'=>"f_bank", "title"=>"Bank", 
      'type'=>"select", "titles"=>$banks},
{'field'=>"f_isres", "type"=>"select", 
      "titles"=>[
        {'value'=>"yes", 'title'=>"да"},
        {'value'=>"no", 'title'=>"нет"},
      ]
      , "title"=>"Резидент"
    },
#     {'field'=>"f_percent", "title"=>"Процент за приход (ГРН)",
#     'default'=>0},
#     {'field'=>"f_okpo", 
#       , "title"=>"OKPO"
#     },

    {'field'=>"f_uah", "no_add_edit"=>1, "title"=>"Баланс, гривна"},
    {'field'=>"f_usd", "no_add_edit"=>1, "title"=>"Бланс, доллар"},
    {'field'=>"f_eur", "no_add_edit"=>1, "title"=>"Баланс, евро"},
  ],
};
#     $proto->{fields}->[5]->{titles}=$firm_services;

    return 'firm';
}
sub setup
{
  my $self = shift;
  $self->start_mode('list');  
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'add'  => 'add',
    'edit' => 'edit',
    'del'  => 'del',
  );
}

sub list
{
   my $self = shift;
   #   $proto->{'sort'}='f_id DESC';    	
   return $self->proto_list($proto);
}

sub add
{
   my $self = shift;
   $proto->{'page_title'}='Добавить новую фирму';
   return $self->proto_add_edit('add', $proto);
}

sub edit
{
   my $self = shift;
   $proto->{'page_title'}='Редактировать фирму';

   return $self->proto_add_edit('edit', $proto);
}

sub del
{
   my $self = shift;
   return $self->proto_action('del', $proto);
}


1;
