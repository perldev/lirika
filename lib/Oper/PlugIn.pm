package Oper::PlugIn;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $proto;
sub setup
{
  my $self = shift;
  $self->start_mode('list');  

  $self->run_modes(
       'AUTOLOAD'=>'list',
       'get' => 'get',
       'list' => 'list',
       'add'=>'add',
       'edit'=>'edit'
  );
}
sub list{
    my $self=shift;
    return $self->proto_list_short($proto);
}
sub get_right{
    my $self=shift;

        $proto={
        'table'=>"plugins",
        'template_prefix'=>"plugins",
        'page_title'=>'Плагины',
        'sort'=>'p_ts desc',
        'fields'=>[
            {'field'=>"p_id", "title"=>"ID", "no_add_edit"=>1,filter=>'='}, #first field is ID
            {'field'=>"p_desc", "title"=>"Комментарии ",filter=>'like'},
            {
            'field'=>'p_name',"title"=>"Идентификатор",filter=>'like'
            },
            {
            'field'=>'p_code',"title"=>"Код плагина",category=>'rich_text',cols=>90,rows=>40,
            },
            {
            'field'=>'p_prototype',"title"=>"Код шаблона",category=>'rich_text',cols=>90,rows=>40,
            },
            {
              'field'=>"p_oid", "title"=>"Автор"    
            , "no_add_edit"=>1, "category"=>"operators"
            },
            {
               'field'=>"p_ts", "title"=>"Дата заведения"
            , "no_add_edit"=>1, 
            },
            {
              'field'=>"p_last_oid_edited", "title"=>"Автор последних изменения",  "no_add_edit"=>1, "category"=>"operators"
            },
            {
            'field'=>"p_last_ts_edited", "title"=>"Дата изменений","no_add_edit"=>1,
            },
        ],
        };
        return 'plugins';


}
sub add{

    my $self=shift;
    return $self->proto_add_edit('add',$proto);

}
sub edit{
    my $self=shift;
    $proto->{fields}->[2]->{no_add_edit}=1;
    
    return $self->proto_add_edit('edit',$proto);
}

sub get{
      my $self=shift;

      my $aid=$self->query->param('ct_aid');
      my $name=$self->query->param('name');
      my ($prototype,$code)=$dbh->selectrow_array(q[SELECT 
                                                       p_prototype,p_code
                                                       FROM plugins WHERE p_name=? ],undef,$name);
      my $proto_hash;
      eval "$code";
      if($@){
        die $@;
      }
      my $output ="";
      my $tmpl=$self->load_tmpl("$PLUGIN_TMPL"."$name.html");
      $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
      return $output; 


}
sub proto_add_edit_trigger{
  my $self=shift;
  my $params = shift;
  if($params->{step} eq 'before'&&$params->{method} eq 'add'){

    my $tmpl=$self->query->param('p_prototype');
    my $name=$self->query->param('p_name');


    open(FL,">$DIR/$PLUGIN_TMPL"."$name.html") || die $!;
    print FL $tmpl;
    close(FL);

    foreach my $row( @{$params->{proto}->{fields}} ){
        if($row->{field} eq 'p_oid'){
        $row->{expr} = $self->{user_id};
        
        }
  
     }
   
     
 

   return 1;   

  }elsif($params->{step} eq 'operation'){

    $dbh->do($params->{sql});
    return 1;
    
  }elsif($params->{step} eq 'before'&&$params->{method} eq 'edit'){
    
    my $tmpl=$self->query->param('p_prototype');
    my $name=$dbh->selectrow_array(q[SELECT p_name FROM plugins WHERE p_id=?],undef,$self->query->param('id'));
    
    unlink("$DIR/$PLUGIN_TMPL$name.html") or die $!;
    
    open(FL,">$DIR/$PLUGIN_TMPL$name.html") || die $!;
    print FL $tmpl;
    close(FL);
        foreach my $row( @{$params->{proto}->{fields}} ){
            if($row->{field} eq 'p_last_ts_edited'){
                $row->{expr} = "NOW()";
                next;
            }elsif($row->{field} eq 'p_last_oid_edited'){
                $row->{expr} = $self->{user_id};
                next
            }
    
        }


  }


}



1;
