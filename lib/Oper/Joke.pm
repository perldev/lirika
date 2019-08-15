package Oper::Joke;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $RIGHT='class';


my $proto={
  'table'=>"joke", 
  'page_title'=>'шутки ради',
  'template_prefix'=>"joke",
  'sort'=>'id DESC ', 
  'fields'=>[
   {'field'=>"id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
   {'field'=>"comment", "title"=>"Шутка",filter=>'like'},

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
  );
}
sub list
{
   my $self = shift;
   return $self->proto_list($proto);
}
sub get_right
{
        my $self=shift;
        return 'joke';
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
