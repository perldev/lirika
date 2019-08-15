package Oper::EmailSettings;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $RIGHT='settings';
my $proto;
sub get_right{
        my $self=shift;
 
        $proto={
        'table'=>"emails", 
        'page_title'=>'Настройки почтовой рассылки',
        'template_prefix'=>"emails",
        'fields'=>[
        {'field'=>'em_id', "title"=>"ID", "no_add_edit"=>1}, #first field is ID
        {'field'=>'em_mail', "title"=>"Email",filter=>'like'},
        {'field'=>'em_smtp', "title"=>"Сервер smtp",filter=>'like'},
        {'field'=>'em_user','title'=>"Пользователь",filter=>'like'},	
        {'field'=>'em_pwd','title'=>"Пароль"},
        {'field'=>'em_port','title'=>"Порт(по умолчанию 25)",'default'=>25}
        ]
            
        };
       return 'settings';
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
   return $self->proto_list($proto);
}


sub add
{
   my $self = shift;
   $proto->{page_title}='Добавление нового';
   return $self->proto_add_edit('add', $proto);
}

sub edit
{
   my $self = shift;
    $proto->{page_title}='Редактирование';
      return $self->proto_add_edit('edit', $proto);
}

sub del
{
   my $self = shift;

     $dbh->do(
       qq[DELETE FROM  emails WHERE em_id=?],
       undef,
       $self->query->param('id')
     );
	$self->header_type('redirect');
     return $self->header_add(-url=>'?');


}





1;
