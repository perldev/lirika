package Oper::Notes;
use strict;
use base 'CGIBaseOut';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $RIGHT='index';


my $proto={
  'table'=>"operators_notes", 
  'page_title'=>'Персональные заметки',
  'template_prefix'=>"notes",
  'fields'=>[
	{'field'=>"id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
	{'field'=>"title", "title"=>"Заглавие",filter=>'like'},
	{'field'=>"comment", "title"=>"Текст",filter=>'like',category=>'rich_text'},
	{'field'=>"ts", "no_add_edit"=>1,"add_expr"=>'NOW()',
	"title"=>"Добавлена "},
	{'field'=>"date", "title"=>"На какое число: ", 'filter'=>"time",category=>'date'},
	
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
   $proto->{'extra_where'}="o_id=".$self->{user_id};
   return $self->proto_list($proto);
}
sub get_right
{
        my $self=shift;
        return 'index';
}

sub add
{
   my $self = shift;
   push @{ $proto->{fields} },
	{'field'=>"o_id", "no_add_edit"=>1, "add_expr"=>$self->{user_id}, 'no_view'=>1};
     
   return $self->proto_add_edit('add', $proto);
}
sub edit
{
   my $self = shift;
   push @{ $proto->{fields} },
	{'field'=>"o_id", "no_add_edit"=>1, "add_expr"=>$self->{user_id}, 'no_view'=>1};

   return $self->proto_add_edit('edit', $proto);
}
