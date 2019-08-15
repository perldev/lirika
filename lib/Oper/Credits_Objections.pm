package Oper::Credits_Objections;
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
  'table'=>"credit_objections",
  'page_title'=>'Условия кредитов',
  'extra_where'=>"fs_id<-100 AND fs_id>=-103",
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
  ],
};
        return 'credit_perms';
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
       my $sth=$dbh->prepare("SELECT * FROM firm_services WHERE $proto->{extra_where}  AND fs_status!='deleted' AND   1 ORDER BY fs_name");
      $sth->execute();
      my @res;
      while(my $r=$sth->fetchrow_hashref())
       {
		my $ref=get_client_classes($r->{fs_id});
		
		$r->{fs_percents}=$ref;
		push @res,$r;
		
       }

       $sth->finish();
	
       $self->{tpl_vars}->{rows}=\@res;
       $self->{tpl_vars}->{list_colspan}=$size;
       $self->{tpl_vars}->{classes}=$classes;
        my $tmpl=$self->load_tmpl('credit_objections_list.html');
        my $output='';
        $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
        return $output;
        
}

sub edit
{
   my $self = shift;
   $proto->{page_title}='Редактировать условия кредитов';
   my $arr=$proto->{fields};
   my $res_arr=[];
  $proto->{table}='firm_services';
##get client personal settings
  my $classes=get_client_classes($self->query->param('id'));
   push @$res_arr,$arr->[0];
   push @$res_arr,$arr->[1];
   map {push @$res_arr, {'field'=>"c_id_".$_->{c_id}, "title"=>"% Комиссия для ".$_->{c_name},'value'=>"$_->{'sc_percent'}",no_base=>1,"positive"=>1,'system'=>1}
   } @$classes;
   push @$res_arr,$arr->[2];
  $proto->{fields}=$res_arr;



  return $self->proto_add_edit('edit', $proto);
}
# sub del
# {
#    my $self = shift;
#    my $id= $self->query->param('id');
#    $dbh->do('DELETE FROM services_class WHERE  sc_fsid=? ',undef,$id);##extanded
#    return $self->proto_action('del', $proto);
# }

sub proto_add_edit_trigger{
  my $self=shift;
  my $params = shift;    

  if($params->{method} eq 'add'&&$params->{step} eq 'operation'){
  $dbh->do($params->{sql});

  	my $id=$dbh->selectrow_array('SELECT last_insert_id()');
	if($id)	
	{
  		my $classes=get_classes();
		foreach(@$classes)
		{
				
				$dbh->do('INSERT INTO services_class  SET sc_fsid=?,sc_cid=?,sc_percent=? ',undef,$id,$_->{c_id},$self->query->param('c_id_'.$_->{c_id}));
				
			
			
		
		
		}
	}    
  }elsif($params->{method} eq 'edit'&&$params->{step} eq 'operation')
  {
	
	 my  $id=$self->query->param('id');
	 $dbh->do($params->{sql});
         my $classes=get_classes();
	 foreach(@$classes)
	 {
				
				$dbh->do('INSERT INTO services_class  SET sc_fsid=?,sc_cid=?,sc_percent=? ON DUPLICATE KEY UPDATE  
			       sc_percent=?
				 ',undef,$id,$_->{c_id},$self->query->param('c_id_'.$_->{c_id}),$self->query->param('c_id_'.$_->{c_id}));
				
			
	 }
	  
  }

}



1;