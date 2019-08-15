package Oper::FirmServices;

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
        'table'=>"firm_services",
        'page_title'=>'Услуги фирмы',
        'extra_where'=>"fs_id>0",
        'fields'=>[
            {'field'=>"fs_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
            {'field'=>"fs_name", "title"=>"Название"},
        
            {'field'=>"fs_status", "type"=>"select", "del_value"=>"deleted",
            "titles"=>[
                {'value'=>"active", 'title'=>"активен"},
                {'value'=>"blocked", 'title'=>"заблокирован"},
            ]
            , "title"=>"Cтатус"
            },
            {'field'=>"fs_type", "type"=>"select", 
            "titles"=>[
                {'value'=>"only_in", 'title'=>"только внутри"},
                {'value'=>"out", 'title'=>"внешние"},
            ]
            , "title"=>"Тип"
            },
        ],
        };
       return 'fservice';
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
  );
}

sub list
{
   my $self = shift;
      my $classes=get_classes();
      my $size=@$classes;
     
       my $sth=$dbh->prepare("SELECT * FROM firm_services WHERE fs_id>0 AND fs_status!='deleted' AND   1 ORDER BY fs_name");
      $sth->execute();
      my @res;
      while(my $r=$sth->fetchrow_hashref())
       {
		my $ref=get_client_classes($r->{fs_id});
		
		$r->{fs_percents}=$ref;
		push @res,$r;
		
       }

       $sth->finish();
       $self->{tpl_vars}->{page_title}=$proto->{page_title}='Услуги фирмы';
       $self->{tpl_vars}->{rows}=\@res;
       $self->{tpl_vars}->{list_colspan}=$size;
       $self->{tpl_vars}->{classes}=$classes;
        my $tmpl=$self->load_tmpl('firm_services_list.html');
        my $output='';
        $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
        return $output;
        
}

sub add
{
   my $self = shift;
   $proto->{page_title}='Добавить новую услугу(здесь задаются значения по умолчанию для различны классов карточек)';
  
   my $classes=get_classes();
###generate availible classes;
   my $arr=$proto->{fields};
   my $res_arr=[];
   push @$res_arr,$arr->[0];
   push @$res_arr,$arr->[1];

   map {push @$res_arr, {'field'=>"c_id_".$_->{c_id}, "title"=>"% Комиссия для ".$_->{c_name},no_base=>1}
} @$classes;
  push @$res_arr,$arr->[2];
push @$res_arr,$arr->[3];
  $proto->{fields}=$res_arr;

   return $self->proto_add_edit('add', $proto);
}

sub edit
{
   my $self = shift;
   $proto->{page_title}='Редактировать услугу';
   my $arr=$proto->{fields};
   my $res_arr=[];

##get client personal settings
  my $classes=get_client_classes($self->query->param('id'));
   push @$res_arr,$arr->[0];
   push @$res_arr,$arr->[1];
   map {push @$res_arr, {'field'=>"c_id_".$_->{c_id}, "title"=>"% Комиссия для ".$_->{c_name},'value'=>"$_->{'sc_percent'}",no_base=>1,'system'=>1}
   } @$classes;
   push @$res_arr,$arr->[2];
    push @$res_arr,$arr->[3];
  $proto->{fields}=$res_arr;



  return $self->proto_add_edit('edit', $proto);
}
sub del
{
   my $self = shift;
  # my $id= $self->query->param('id');
  # $dbh->do('DELETE FROM services_class WHERE  sc_fsid=? ',undef,$id);##extanded
  # return $self->proto_action('del', $proto);
	$self->header_type('redirect');
   	return $self->header_add(-url=>'#');
}

sub proto_add_edit_trigger{
  my $self=shift;
  my $params = shift;    

  if($params->{method} eq 'add'&&$params->{step} eq 'operation'){
 	$dbh->do($params->{sql});
	my $id=$dbh->selectrow_array('SELECT last_insert_id()');
	
	my %classes_hash;#this hash for updating table of connections user with services
	if($id)	
	{
  		my $classes=get_classes();
		
		foreach(@$classes)
		{
				$classes_hash{$_->{c_id}}=$self->query->param('c_id_'.$_->{c_id});
				$dbh->do('INSERT INTO services_class  
					  SET sc_fsid=?,sc_cid=?,sc_percent=? ',
					  undef,$id,$_->{c_id},$classes_hash{$_->{c_id}});
		}
	}
	###adding the percents to the service table
	my $r=get_accounts();
	foreach(@$r)
	{
		$dbh->do('INSERT INTO client_services  SET cs_fsid=?,cs_aid=?,cs_percent=?',undef,$id,$_->{a_id},$classes_hash{$_->{c_id}});
	}
	###
	

    
	}elsif($params->{method} eq 'edit'&&$params->{step} eq 'operation')
	{
		
		my  $id=$self->query->param('id');
		$dbh->do($params->{sql});
		my $classes=get_classes();
		my $percent;    
		foreach(@$classes)
		{
						
					$percent=$self->query->param('c_id_'.$_->{c_id});    
					$percent=0 unless($percent);
					$dbh->do('INSERT INTO services_class  SET sc_fsid=?,sc_cid=?,sc_percent=? 
					ON DUPLICATE KEY UPDATE  
					sc_percent=?
					',undef,$id,$_->{c_id},$percent,$percent);
					
				
		}
		
	}

}



1;