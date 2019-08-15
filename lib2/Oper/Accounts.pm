package Oper::Accounts;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
#use lib $PMS_PATH;
my $RIGHT='account';

#this  package needing the checking of all params

my $proto;

sub setup
{
  my $self = shift;
#  die "here";
#   $self->query->param('a_status','active')	unless($self->query->param('a_status'));

  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'add'  => 'add',
    'edit' => 'edit',
    'del'  => 'del',
    'add_do'=>'add_do',	
    'edit_do'=>'edit_do'
  );
}

sub list
{
   my $self = shift;
#   die "here";
   $proto->{table}='accounts_view';
    $self->{tpl_vars}->{accounts_cats}=get_cats();
    my $params=get_system_last_rates();
    $proto->{UAH}=$params->{UAH};
    $proto->{EUR}=$params->{EUR};
   $proto->{'sort'}=' a_name ASC';
  
   return $self->proto_list($proto);
}
sub add
{
       my $self = shift;


	$self->{tpl_vars}->{page_title}='Добавление новой карточки';
	$self->{tpl_vars}->{services}=get_services();
	#get_services_percents
	my $ref=get_services_percents();
	$self->{tpl_vars}->{classes_percent_services}=$ref;
	$self->{tpl_vars}->{classes}=get_classes();
	$self->{tpl_vars}->{operators}=get_operators();
	$self->{tpl_vars}->{cats}=get_cats();
	

	 my $tmpl=$self->load_tmpl('account_add_edit.html');
         my $output='';
	 $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
         return $output;
 
  




}

sub add_do
{
	my $self=shift;
	my %params;
	map{$params{$_}=$self->query->param($_)} $self->query->param();
	my @ar=$self->query->param('services_percent');
	die " Имя карточки должно быть уникальным \n"	if($dbh->selectrow_array(q[SELECT a_id FROM accounts WHERE a_name=? AND a_status!='deleted'
	],undef,$params{a_name}));	
	
	die " Задайте пароль для архива \n" unless($params{a_report_passwd});
	$params{a_oid}=$self->{user_id}	unless($params{a_oid});

        die "До 24 считать не  умеете? \n"   if(abs(int($params{a_hour_report}))>24);

	$dbh->do(
	q[
		INSERT INTO accounts SET 	
		a_ts=current_timestamp,a_name=?,a_phones=?,a_class=?,a_aid=?,a_email=?,a_hour_report=?,a_issubs=?,a_report_passwd=?,a_oid=?,a_acid=?,a_is_debt=?
	],undef,
	$params{a_name},
	$params{a_phones},
	$params{a_class},
	$params{a_aid},
	$params{a_email},
	$params{a_hour_report},
	$params{a_issubs},
	$params{a_report_passwd},
	$params{a_oid},
	$params{a_acid},
	$params{a_is_debt}
	);
#	$dbh->do(qq[INSERT INTO operators_clients(oc_oid,oc_aid) SELECT $id  FROM operators WHERE o_type='in' ]);
	
	
	my $id=$dbh->selectrow_array(q[SELECT last_insert_id() ]);
        $dbh->do(qq[INSERT INTO operators_accounts_cashier_out(oaco_oid,oaco_aid) SELECT o_id,$id  FROM operators WHERE o_type='in' ]);
	$dbh->do(qq[INSERT INTO accounts (a_name,a_class,a_oid,a_acid,a_status,a_mirror) SELECT a_name,a_class,a_oid,a_acid,'deleted',$id FROM accounts WHERE a_id=? ],undef,$id);

	my $percent;
    



				my $r=$dbh->selectall_hashref(q[SELECT fs_id FROM	
				firm_services WHERE fs_status='active' AND fs_id>0
				],'fs_id');	
			
				foreach(keys %$r)
				{
				
					$percent=$self->query->param("fsp_$_");
					$percent=~s/[,]/\./g;
					$percent=~s/[ \"\'\\]//g;
					$dbh->do(q[INSERT INTO 
					client_services(cs_fsid,
					cs_aid,cs_percent)
				 	VALUES(?,?,?)],undef,$_,$id,
					1*$percent);
				    }
	$dbh->do(qq[INSERT INTO operators_accounts_cashier_out(oaco_oid,oaco_aid)
	SELECT o_id,$id
	FROM operators
	WHERE 1
	AND o_type='in'
	]);
				
	
		
	$self->header_type('redirect');
	return $self->header_add(-url=>'accounts.cgi');
}


sub get_right
{
        my $self=shift;
        my $r=get_classes();
        my $opers=get_operators();
        $proto={
        'page_title'=>'Карточки',
        'table'=>"accounts",  
        'extra_where'=>"a_id not in($firms_id)  AND a_status!='deleted'",
        'sort'=>'a_name ASC ',
        'fields'=>[
            {'field'=>"a_id", "title"=>"ID", "no_add_edit"=>1, 'filter'=>"="}, #first field is ID
            {'field'=>"a_ts", "no_add_edit"=>1, "add_expr"=>"NOW()", "title"=>"Дата"},
            {'field'=>"a_name", "title"=>"ФИО", 'filter'=>"like",uniq=>1},
            {'field'=>"a_phones", "title"=>"Комментарии"},
            {'field'=>"a_email","title"=>"Электронный адрес(email) "},
            {'field'=>"a_class", "type"=>"select", 
            "title"=>"Класс"
            , 'filter'=>"="
            },
             {'field'=>"ac_id", "type"=>"select", 
            "title"=>"Категория",
            titles=>get_cats_simple(),
            , 'filter'=>"="
            },
        {'field'=>"a_oid", "title"=>"Оператор"
            , "no_add_edit"=>1, "category"=>"operators",filter=>'=',type=>'select',titles=>$opers},
            {'field'=>"a_issubs", "type"=>"select",
            "titles"=>[
                {'value'=>"yes", 'title'=>"Подписан"},
                {'value'=>"no", 'title'=>"Не подписан"},
            ]
            , "title"=>"Подписка на уведомление о состоянии счета",filter=>'='
            },
            {'field'=>"a_status", "type"=>"select", "del_value"=>"deleted",
            "titles"=>[
                {'value'=>"active", 'title'=>"активен"},
                {'value'=>"blocked", 'title'=>"заблокирован"},
            ]      , "title"=>"Статус",'filter'=>'='
            },
      {'field'=>"a_is_debt", "type"=>"select",                                                                                
          "titles"=>[                                                                                                                                    
	{'value'=>"no", 'title'=>"Нет"},                                                                                                   
	 {'value'=>"yes", 'title'=>"Да"},                                                                                             
	  ]      , "title"=>"Cверена",'filter'=>'='                                                                                                       
	  },       
        
            {'field'=>"a_aid", "title"=>"Кто привел в банк", "category"=>"accounts", 'may_null'=>1},
            {'field'=>"a_incom_id", "title"=>"Приходная программа", "category"=>"accounts", 'may_null'=>1},
            {'field'=>"a_uah", "no_add_edit"=>1, "title"=>"Баланс, гривна"},
            {'field'=>"a_usd", "no_add_edit"=>1, "title"=>"Бланс, доллар"},
            {'field'=>"a_eur", "no_add_edit"=>1, "title"=>"Баланс, евро"},
        ],
        };
        $proto->{fields}->[5]->{"titles"}=$r;
	   $self->query->param('a_status','active')     unless($self->query->param('a_status'));       

        return 'account';
}
sub edit
{
   	my $self=shift;
	my $id=$self->query->param('id');

	my $row=$dbh->selectrow_hashref(
	q[
		SELECT 
		a_ts,a_id,a_name,a_phones,a_aid,a_email,a_issubs,a_status,a_class,a_report_passwd,
		a_oid,a_acid,a_incom_id,a_hour_report,a_is_debt

		FROM  accounts WHERE a_id=?
	
	],
	undef,$id);

	unless($row->{a_aid})
	{
		$row->{a_aid}='';
	}
	map {$self->{tpl_vars}->{$_}=$row->{$_}} keys %$row;
	$self->{tpl_vars}->{page_title}='Редактирование карточки';
	$self->{tpl_vars}->{services}=get_services();
	
#get_services_percents
	my $ref=get_services_percents();
	$self->{tpl_vars}->{classes_percent_services}=$ref;
	$self->{tpl_vars}->{classes}=get_classes();
 	$self->{tpl_vars}->{client_services_percents}=get_services_percents_client($id);
	$self->{tpl_vars}->{cats}=get_cats($row->{a_acid});
#	use Data::Dumper;
#	die Dumper $self->{tpl_vars}->{accounts_cats};
	$self->{tpl_vars}->{operators}=get_operators($row->{a_oid});
	
	 my $tmpl=$self->load_tmpl('account_add_edit.html');
	
         my $output='';
	 $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
         return $output;
 


}
sub edit_do
{
	my $self=shift;
	my $id=$self->query->param('id');
	my %params;

	map{$params{$_}=$self->query->param($_)} $self->query->param();

	die "<Имя карточки должно быть уникальным>\n"	if($dbh->selectrow_array(q[SELECT a_id FROM accounts WHERE a_name=? AND a_status!='deleted' AND a_id!=?],undef,$params{a_name},$params{id}));		
	die "Задайте пароль для архива \n" unless($params{a_report_passwd});

     die "До 24 считать не  умеете? \n"   if(abs(int($params{a_hour_report}))>24);

	$dbh->do(
	q[
	UPDATE accounts SET 	
	a_name=?,a_phones=?,a_class=?,a_aid=?,a_email=?,a_hour_report=?,a_issubs=?,a_status=?,a_report_passwd=?,
	a_oid=?,a_acid=?,a_incom_id=?,a_is_debt=? WHERE a_id=?
	],undef,
	$params{a_name},$params{a_phones},$params{a_class},$params{a_aid},$params{a_email},$params{a_hour_report},$params{a_issubs},
	$params{a_status},
	$params{a_report_passwd},$params{a_oid},$params{a_acid},$params{a_incom_id},$params{a_is_debt},
	$params{id}
	);

		
				my $r=$dbh->selectall_hashref(q[SELECT fs_id FROM	firm_services WHERE fs_status='active'AND fs_id>0
				],'fs_id');	
				my $tmp;
				$id=~s/[\"\'\\]//g;
				
				foreach(keys %$r)
				{
					
					##there something wrong with DBI!!!((
					$tmp=$self->query->param("fsp_$_");
					$tmp=~s/[\"\' \\]//g;
					$tmp=~s/[,]/\./g;
					
					$_=~s/[\"'\\]//g;
					$tmp=$tmp*1;
					$dbh->do(
					qq[INSERT INTO client_services( 
					 cs_percent,cs_fsid,cs_aid) VALUES($tmp,$_,$id) ON DUPLICATE KEY   
					 UPDATE cs_percent=$tmp
				 	]);

				}
	
	$self->header_type('redirect');
	return $self->header_add(-url=>'?');


}

sub del
{
   my $self = shift;
    $proto->{page_title}='Удаление карточки';
   return $self->proto_action('del', $proto);
}

sub handle_errors_add_trans
{
       return if $^S; # for eval die
        my $msg=join ',', @_;
        print "Content-type: text/html; charset=cp1251\n\n";
	my @arr=split(':',$msg);
	$msg=$arr[1];
	$msg=~s/at(.*)//;
	
        my $tmpl = Template->new(
	{
		INCLUDE_PATH => '../tmpl',
		INTERPOLATE  => 1,               # expand "$var" in plain text
		POST_CHOMP   => 1,               # cleanup whitespace 
		EVAL_PERL    => 1,       
	}
        );

        
        my $vars = {};
        $vars->{error}=$msg;
        $tmpl->process('proto_error.html',$vars) || die $tmpl->error();
        $SIG{__DIE__}=undef;
}

1;