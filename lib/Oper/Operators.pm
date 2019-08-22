package Oper::Operators;

use strict;
use Data::Dumper;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
use CGI::Carp qw(fatalsToBrowser);

my $proto;
sub get_right
{
  my $self=shift;
  
 $proto={
  'table'=>"operators",
  'page_title'=>'Внутренние операторы',
  'extra_where'=>" o_type='in'",
  'fields'=>[
    {'field'=>"o_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
    {'field'=>"o_session_data", "title"=>"o_session_data", "no_add_edit"=>1,"default"=>" "}, #first field is ID
    {'field'=>"o_login", "title"=>"Логин"},
    {'field'=>"o_password", "title"=>"Пароль", "crypt"=>"SHA1"},
    {'field'=>"o_greeding", "title"=>"Приветствие"},
    {'field'=>"o_privileges", "title"=>"Права",
	
     "type"=>"set",
     
    },
    {'field'=>"ch_all1",'title'=>'','system'=>1,"type"=>"set","titles"=>[{'title' => 'Выбрать все'}],java_script_action=>'onclick="checkAllOper(this,\'o_accounts\')"'},	
   {'field'=>"o_accounts", "title"=>"Права Карточки",
      "type"=>"set",
     },
     {'field'=>"ch_all2",'title'=>'','system'=>1,"type"=>"set","titles"=>[{'title' => 'Выбрать все'}],java_script_action=>'onclick="checkAllOper(this,\'o_accounts_view\')"'},	

     {'field'=>"o_accounts_view", "title"=>"Права на просмотр Карточки",
      "type"=>"set",
     },
    {'field'=>"o_status", "type"=>"select", "del_value"=>"deleted",
      "titles"=>[
        {'value'=>"active", 'title'=>"активен"},
        {'value'=>"blocked", 'title'=>"заблокирован"},
      ]
      , "title"=>"Статус"
    },
   {'field'=>"o_menu_type", "type"=>"select", 
      "titles"=>[
        {'value'=>"line", 'title'=>"В линию"},
        {'value'=>"grid", 'title'=>"Блоками"},
      ]
      , "title"=>"Тип Меню"
    },
  ],
};

   $proto->{fields}->[5]->{"titles"}=get_desc_rights_array();
   $proto->{fields}->[7]->{"titles"}=get_accounts_simple_with_block();
   $proto->{fields}->[9]->{"titles"}=get_accounts_simple_with_block();
   #die(Dumper($proto->{fields}));


   my $id=$self->query->param('id');
   $id=int($id)*1;
   if($id){
        my $ref=$dbh->selectall_hashref(qq[SELECT 
        oaco_aid FROM operators_accounts_cashier_out WHERE oaco_oid=$id],'oaco_aid');
        $proto->{fields}->[7]->{'val'}=join('|',keys %{ $ref });
        my $ref=$dbh->selectall_hashref(qq[SELECT 
        oaav_aid FROM operators_accounts_access_view WHERE oaav_oid=$id],'oaav_aid');
        $proto->{fields}->[9]->{'val'}=join('|',keys %{ $ref });

    }
   #die Dumper $proto;
   return 'oper';
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
    'list_out'=>'list_out',
    'add_out'  => 'add_out',
    'edit_out' => 'edit_out',
    'add_out_do'  => 'add_out_do',
    'edit_out_do' => 'edit_out_do',
    'del_out'  => 'del_out',


  );
}
sub edit_out
{
	my $self=shift;
	my $o_id=$self->query->param('id');

	my $tmpl=$self->load_tmpl('operators_out_add.html');
        my $output='';

	$self->{tpl_vars}->{page_title}='Редактировать внешний операторский аккаунт';
	$self->{tpl_vars}->{my_action}='edit_out_do';
	my $operator=$dbh->selectrow_hashref(q[SELECT * FROM operators WHERE o_id=?],undef,$o_id);
	unless($operator->{o_id})
	{
		$self->header_type('redirect');
		return $self->header_type(-url=>'?do=list_out');
	}
	map{ $self->{tpl_vars}->{operators}->{$_}=$operator->{$_} } keys %$operator;
	
	my $sth=$dbh->prepare(q[SELECT a_name,a_id,oc_aid  FROM accounts LEFT JOIN  operators_clients 
	ON (oc_aid=a_id AND 
	oc_oid=?) WHERE a_status='active' AND a_id>0]);
	$sth->execute($o_id);
	my @privs;
	while(my $r=$sth->fetchrow_hashref())
	{
		push @privs,$r;	
	}
	
	$sth->finish();
	$self->{tpl_vars}->{privs}=\@privs;
	
	my $sth1=$dbh->prepare(q[SELECT f_name,f_id,of_fid  FROM firms LEFT JOIN  operators_firms 
	ON (of_fid=f_id AND of_oid=?) WHERE f_status='active' AND f_id>0]);
	$sth1->execute($o_id);
	my @privs_f;
	while(my $r=$sth1->fetchrow_hashref())
	{
		push @privs_f,$r;	
	}
	$sth1->finish();
	$self->{tpl_vars}->{firm_privs}=\@privs_f;
        die Dumper $self->{tpl_vars};


   	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || 
        $tmpl->error();
        return $output;
}
sub edit_out_do
{
	my $self=shift;
	my $id=$self->query->param('id');
	my $o_status=$self->query->param('o_status');
	my $o_login=$self->query->param('o_login');
	my $o_password=$self->query->param('o_password');
	my @ar=$self->query->param('privs');
	my @ar_f=$self->query->param('firm_privs');

	unless($id)
	{
		$self->header_type('redirect');
		return $self->header_type(-url=>'?do=list_out');
	}
	
	return $self->error( "Поле login не заполнили")	unless($o_login);
	
	my $o_id=$dbh->selectrow_hashref(q[SELECT o_id FROM operators WHERE o_id!=?  AND o_status IN ('active','blocked') AND o_login=?],undef,$id,$o_login);
	

	return $self->error( "Такой  login уже занят")	if($o_id->{o_id});


	#die "Поле o_password не заполнили"	unless($o_password);

	
	$dbh->do(q[DELETE FROM 	operators_clients WHERE oc_oid=?],undef,$id);
		$dbh->do(q[DELETE FROM 	operators_firms WHERE of_oid=? ],undef,$id);

	
#	$dbh->do(q[DELETE FROM 	operators_clients WHERE oc_oid=?],undef,$id);
	if($o_password)
	{
		$dbh->do(q[UPDATE operators 
		SET o_type='out',o_login=?,o_password=SHA1(?),o_status=? WHERE 
		o_id=?],undef,$o_login,$o_password,$o_status,$id);
	}else
	{
		$dbh->do(q[UPDATE operators 
		SET o_type='out',o_login=?,o_status=? WHERE 
		o_id=?],undef,$o_login,$o_status,$id);
	}

	map{$dbh->do(q[INSERT INTO operators_clients SET oc_aid=?,oc_oid=? 
	ON DUPLICATE KEY UPDATE oc_aid=?,oc_oid=?],undef,$_,$id,$_,$id)} @ar;

	map{$dbh->do(q[INSERT INTO operators_firms SET of_fid=?,of_oid=? 
	ON DUPLICATE KEY UPDATE of_fid=?,of_oid=?],undef,$_,$id,$_,$id)} @ar_f;

	$self->header_type('redirect');
	return $self->header_add(-url=>'?do=list_out');

}
sub add_out_do
{
	my $self=shift;
	my @ar=$self->query->param('privs');
	my @ar_f=$self->query->param('firm_privs');
	my $o_status=$self->query->param('o_status');
	my $o_login=$self->query->param('o_login');
	my $o_password=$self->query->param('o_password');
	
	
	return $self->error("Поле login не заполнили")	unless($o_login);
	
	my $o_id=$dbh->selectrow_array(q[SELECT o_id FROM operators 
	WHERE o_login=? AND o_status!='deleted'],undef,$o_login);

	return $self->error( "Такой  login уже занят")	if($o_id);

	return $self->error( "Поле o_password не заполнили")	unless($o_password);


	$dbh->do(q[INSERT INTO operators 
	SET o_type='out',o_login=?,o_password=SHA1(?),o_status=?],undef,$o_login,$o_password,$o_status);
	my $id=$dbh->selectrow_array(q[SELECT last_insert_id()]);
	map{$dbh->do(q[INSERT INTO operators_clients SET oc_aid=?,oc_oid=? 
	ON DUPLICATE KEY UPDATE oc_aid=?,oc_oid=?],undef,$_,$id,$_,$id)} @ar;

	map{$dbh->do(q[INSERT INTO operators_firms SET of_fid=?,of_oid=? 
	ON DUPLICATE KEY UPDATE of_fid=?,of_oid=?],undef,$_,$id,$_,$id)} @ar_f;

	$self->header_type('redirect');
	return $self->header_add(-url=>'?do=list_out');


}
sub add_out
{
	my $self=shift;
	$self->{tpl_vars}->{page_title}='Добавить внешний операторский аккаунт';
	$self->{tpl_vars}->{my_action}='add_out_do';
	my $tmpl=$self->load_tmpl('operators_out_add.html');
        my $output='';
	my $sth=$dbh->prepare(q[SELECT a_name,a_id FROM accounts WHERE a_status='active' AND a_id>0]);
	$sth->execute();
	my @privs;
	while(my $r=$sth->fetchrow_hashref())
	{
		push @privs,$r;	
	}
	$sth->finish();
	$self->{tpl_vars}->{privs}=\@privs;

	my $sth1=$dbh->prepare(q[SELECT f_name,f_id FROM firms WHERE f_status='active' AND f_id>0]);
	$sth1->execute();
	my @privs_f;
	while(my $r=$sth1->fetchrow_hashref())
	{
		push @privs_f,$r;	
	}
	$sth1->finish();
	$self->{tpl_vars}->{firm_privs}=\@privs_f;
        $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || 
        $tmpl->error();
        return $output;

}
sub proto_add_edit_trigger
{
    my $self=shift;
    my $params=shift;
    if($params->{step} eq 'before'){

       $proto->{fields}->[7]->{no_add_edit}=1;
       $proto->{fields}->[9]->{no_add_edit}=1;

      }elsif($params->{step} eq 'operation'){
        
        my @ids=();
        #o_accounts__725
        my $id=$self->query->param('id');
        $dbh->do($params->{sql});
        $id = $dbh->selectrow_array(q[SELECT last_insert_id() ]) unless($id);

        my $str=q[INSERT INTO operators_accounts_cashier_out(oaco_oid,oaco_aid) VALUES];
        foreach my $key (@{$proto->{fields}->[7]->{titles}}){
           if($self->query->param("o_accounts__$key->{value}")){
               $str.="($id,$key->{value}),";
               push @ids,$key->{value};
            }

        }
       

        my @ids_view=();
        my $str2=q[INSERT INTO operators_accounts_access_view(oaav_oid,oaav_aid) VALUES];
        foreach my $k (@{$proto->{fields}->[9]->{titles}}){
           
           if($self->query->param("o_accounts_view__$k->{value}")){
               $str2.="($id,$k->{value}),";
               push @ids_view,$k->{value};
            }

        }
        $dbh->do(q[DELETE FROM operators_accounts_cashier_out WHERE oaco_oid=?],undef,$id);
        $dbh->do(q[DELETE FROM operators_accounts_access_view WHERE oaav_oid=?],undef,$id);
        if(@ids){
            chop($str);
            $dbh->do($str);
        }
        
        if(@ids_view){
            chop($str2);
            $dbh->do($str2);
        }

    }

}
sub list_out
{
	my $self=shift;
	$proto->{page_title}='Внешние операторы';

	$proto->{extra_where}=q[ o_type='out' ];
	$proto->{template_prefix}='operators_out';
	my $sth=$dbh->prepare(q[SELECT * FROM clients_out_operators]);
	my %hash;
	$proto->{accounts_rights}=\%hash;
	$sth->execute();

	while(my $r=$sth->fetchrow_hashref())
	{
		$hash{$r->{o_id}}.=qq[$r->{a_name},];
			
	}
	
	$sth->finish();
	map{chop($hash{$_}) } keys %hash;

	
	my $sth1=$dbh->prepare(q[SELECT * FROM firms_out_operators]);
	my %hash1;
	$proto->{accounts_firms_rights}=\%hash1;
	$sth1->execute();

	while(my $r=$sth1->fetchrow_hashref())
	{
		$hash1{$r->{o_id}}.=qq[$r->{f_name},];
			
	}
	
	$sth1->finish();
	map{chop($hash1{$_}) } keys %hash1;



	
	return $self->proto_list($proto,{fetch_row=>\&operators_list});
}
sub del_out
{
	my $self=shift;
	my $id=$self->query->param('id');
	$dbh->do(q[DELETE FROM operators WHERE o_id=?],undef,$id);
	$dbh->do(q[DELETE FROM oper_sessions WHERE os_oid=?],undef,$id);
	$dbh->do(q[DELETE FROM operators_clients WHERE oc_oid=?],undef,$id);
	$dbh->do(q[DELETE FROM operators_firms WHERE of_oid=?],undef,$id);
	$self->header_type('redirect');
	return $self->header_add(-url=>'?do=list_out');

}

sub list
{
   my $self = shift;
#    use Data::Dumper;
#    die Dumper $proto;
   return $self->proto_list($proto);
}
sub operators_list
{
	my ($array,$row,$prev_row,$proto)=@_;
	$row->{o_privileges}=$proto->{accounts_rights}->{$row->{o_id}};
	$row->{o_privileges_firms}=$proto->{accounts_firms_rights}->{$row->{o_id}};
	
	
	push @$array,$row;
}


sub add{

   my $self = shift;
   $proto->{page_title}='Добавить операторский аккаунт';
    
   return $self->proto_add_edit('add', $proto);
}

sub edit
{
   my $self = shift;
   $proto->{page_title}='Редактировать операторский аккаунт';
   return $self->proto_add_edit('edit', $proto);
}

sub del
{
   my $self = shift;

   $proto->{page_title}='Удаление  операторского аккаунта';
   return $self->proto_action('del', $proto);
}


1;
