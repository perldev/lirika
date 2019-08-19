package Oper::Banks;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $RIGHT='class';


my $proto={
  'table'=>"banks", 
  'page_title'=>'Классы клиентов',
  'template_prefix'=>"banks",
  
  'fields'=>[
   {'field'=>"c_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
   {'field'=>"c_name", "title"=>"Наименование банков"},
   {'field'=>'c_comments','title'=>"Краткое описание"}	
#    {'field'=>"c_ts", "no_add_edit"=>1,'filter'=>"time",  "title"=>"Дата введения"},

]
    
};

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
#    $self->param('c_ts','');
   return $self->proto_list($proto);
}
sub get_right
{
        my $self=shift;

        return 'class';
}

sub add
{
   my $self = shift;
   $proto->{page_title}='Добавление нового банка';
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
       qq[DELETE FROM  banks WHERE c_id=?],
       undef,
       $self->query->param('id')
     );
     
     $self->header_type('redirect');
     return $self->header_add(-url=>'?');


}
sub proto_add_edit_trigger{
  my $self=shift;
  my $params = shift;    

  if($params->{method} eq 'add'&&$params->{step} eq 'operation'){
  	
	$dbh->do($params->{sql});
	my $id=$dbh->selectrow_array('SELECT last_insert_id()');
	
  }elsif($params->{method} eq 'edit'&&$params->{step} eq 'operation')
  {
		$dbh->do($params->{sql});

  }
      
}





1;
