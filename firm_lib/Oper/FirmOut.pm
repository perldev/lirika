package Oper::FirmOut;
use strict;
use base 'CGIBaseOut';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $RIGHT='index';


my $proto={
  'table'=>"out_firms", 
  'page_title'=>'Архив контрагентов',
  'template_prefix'=>"firm_out",
   'sort'=>'of_ts DESC',
  'fields'=>[
	{'field'=>"of_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
	{'field'=>"of_name", "title"=>"Название",filter=>'like'},
	{'field'=>"of_okpo", "title"=>"ОКПО",filter=>'like'},
	{'field'=>"of_ts", "no_add_edit"=>1,"add_expr"=>'NOW()',"title"=>"Дата занесения"},
	{'field'=>"of_oid", "title"=>"Добавил",
	'no_add_edit'=>1, 
	'filter'=>"=",
	type=>'select',no_view=>1,
	 'titles'=>get_out_operators},
	
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
        return 'index';
}

sub add
{
   my $self = shift;
     
   return $self->proto_add_edit('add', $proto);
}
sub proto_add_edit_trigger{

my $self=shift;
  my $params = shift;    
  my $do=$self->query->param('do');
  my $id=$self->query->param('id');

    
    
    
  if($params->{step} eq 'before'){
   
    
    


   foreach my $row( @{$params->{proto}->{fields}} ){
     if($row->{field} eq 'of_oid'){
       $row->{expr} = $self->{user_id}
     }
  
     

  }

   return 1;   

  }elsif($params->{step} eq 'operation'){
   
		if($do eq 'edit'&&defined($id)&&$id ne ''){
		    my $ref=$dbh->selectrow_hashref(q[SELECT of_name,of_okpo FROM out_firms 
					      WHERE of_id=?],undef,$id);
			
# create table out_firms_history(ofh_id int(11) 
# auto_increment primary key,
# ofh_ts timestamp default current_timestamp, 
# ofh_ofid int(11) not NULL,
# ofh_oid int(11),ofh_old_name varchar(255),ofh_old_okpo varchar(255) ) default charset cp1251;
		##filling the history
		    $dbh->do('INSERT INTO out_firms_history(ofh_oid,ofh_ofid,ofh_old_name,ofh_old_okpo) 
			      VALUES(?,?,?,?)',undef,$self->{user_id},$id,$ref->{of_name},$ref->{of_okpo});
		}
	      $dbh->do($params->{sql});

	
	##if it's adding and 	we have an id not empty id param

  }



}
sub edit
{
   my $self = shift;
   return $self->proto_add_edit('edit', $proto);
}
