package Oper::Docs;
use strict;
use base 'CGIBaseOut';
use SiteConfig;
use SiteDB;
use SiteCommon;
# $SIG{__DIE__}=\&handle_errors;

sub handle_errors
{
        return if $^S; # for eval die
        my $msg=join ',', @_;
        print "Content-type: text/html; charset=cp1251\n\n";
	my @arr=split(':',$msg);
	$msg=$arr[1];
	$msg=~s/at(.*)//;
	
        my $tmpl = Template->new(
	{
		INCLUDE_PATH => '../tmpl_firm',
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
# .50      ГРН     ЕКБ-услуги банка        Dashka (id#47)      12.07.2010 11:41       удалена     
# 401858  07.07.2010      КИФ Стратегия (id#199)  стратегия (id#3423)     - 425   ГРН     Инфоксводоканал-замена и поверка водомера   Dashka (id#47)  12.07.2010 11:41 

my $proto={
  
  'table'=>"documents_transactions_view",  
  'template_prefix'=>"docs_transactions",
  'extra_where'=>"dt_status='created' ",
  'extra_where2'=>"dt_status='processed' ",
  'need_confirmation'=>1,

  'page_title'=>"Документы по фирмам",
  'sort'=>'dt_ts DESC',
  'fields'=>[
    {'field'=>"dt_date",  "title"=>"Дата", 'filter'=>"time",category=>'date'},
    
    {
	'field'=>"dt_fid", "title"=>"Фирма", 'filter'=>"="
      , "type"=>"select",
      , "category"=>'firms',
    },
    {
	'field'=>"dt_ofid", "title"=>"Покупатель", 'filter'=>"="
      , "type"=>"select",
	titles=>get_out_firms(),
   	another_enable=>1,
   	#extended_search=>1,
   	search_field=>1,
	okpo_enable=>1,
	firms_okpo=>get_out_firms_okpo(),
	search_field_function=>'onkeyup="search_in_select_field(this,\'dt_ofid\');search_select_change(\'dt_ofid\',\'dt_okpo\');"',
	java_script_action => 'onchange="search_select_change(\'dt_ofid\',\'dt_okpo\')"',
    },
    {
	'field'=>"dt_okpo", "title"=>"Окпо",
	okpo_enable=>1,
	firms_okpo=>get_out_firms_okpo(),
	java_script_action => 'onkeyup="search_on_okpo(this,\'dt_ofid\')"',
    'system'=>1
    },
    {  
	'field'=>"dt_aid", "title"=>"Программа",'filter'=>"="
      , "type"=>"select",
      , titles=>get_clients_accounts(),
   	search_field=>1,
   	
    },
    {'field'=>"dt_oid", "no_view"=>1},
    {'field'=>"dt_amnt",positive=>1, "title"=>"Сумма", 'filter'=>"=",component_function=>\&search_amnt_confirm},
    {'field'=>"dt_comment", "title"=>"Назначение",default=>'Приходные документы'},
    {'field'=>"dt_drid", no_view=>1},
    {'field'=>"dt_infl", no_view=>1},
    {'field'=>"dt_status", no_view=>1},


  ],
};
sub search_amnt_confirm
{
    my ($field,$self)=@_;

    my $query=$self->query;
    my $val=$query->param($field->{field});
    my $fid=$query->param('dt_fid');
    my $ofid2 = $query->param('extended_search');
    my $ofid=$query->param('dt_ofid');
	$ofid = $ofid2 if($ofid2>0);
    my $date=$query->param('dt_date');
    $date=~/(\d\d\d\d)-(\d{1,2})-(\d{1,2})/;
    $date=$2;
    $date=$date*1;

    $date="$date-$1";
    my $aid=$query->param('dt_aid');

    my $aids=get_accounts_hash();
    my $ofids=get_out_firms_hash();
    my $fids=get_firms_hash();
    
    $val=~s/[^\d\.]//g;

    my $hash=$dbh->selectall_hashref(qq[SELECT 
    dt_id,
    dt_fid,
    dt_ofid,
    dt_aid,
    CONCAT(MONTH(dt_date),'-',YEAR(dt_date)) as dt_date,
    CONCAT(MONTH(dt_date),'.',YEAR(dt_date)) as dt_date_title
    FROM documents_transactions 
    WHERE 
    ceil($val)=ceil(dt_amnt) 
    AND dt_status!='canceled' AND dt_oid=$self->{user_id} ],'dt_id');
    $field->{extended_value}=" Совпадений не найдено";
    return $val  if(! keys %{$hash} );
 #   $field->{extended_value}="<strong>Найдены совпадения, просмотрите пожайлуста</strong> подробнее";
     

    my @whole;
    my @whole_firm;
    my @whole_out_firm;
    my @whole_account;
    my @whole_date;

    foreach(keys %{$hash})
    {
   

       $hash->{$_}->{dt_fid_title}=$fids->{ $hash->{$_}->{dt_fid} }->{title};
       $hash->{$_}->{dt_ofid_title}=$ofids->{ $hash->{$_}->{dt_ofid} }->{title};
       $hash->{$_}->{dt_aid_title}=$aids->{ $hash->{$_}->{dt_aid} }->{title};
 
        
        if($hash->{$_}->{dt_fid}==$fid
        &&$hash->{$_}->{dt_ofid}==$ofid
        &&$hash->{$_}->{dt_date}==$date
        &&$hash->{$_}->{dt_aid}==$aid)
        {
            push @whole,$hash->{$_};
            next;
        }
    
         if($hash->{$_}->{dt_fid}==$fid)
         {
            push @whole_firm,$hash->{$_};
            next;

        }
        if($hash->{$_}->{dt_ofid}==$ofid)
        {
            push @whole_out_firm,$hash->{$_};
            next;

        }
        if($hash->{$_}->{dt_aid}==$aid)
        {
            push @whole_account,$hash->{$_};
            next;

        }
        if($hash->{$_}->{dt_date} eq $date)
        {
            push @whole_date,$hash->{$_};
            next;

        }
    }
    my $params={};
    
    $params->{file}='search_amnts_list.html';

    $params->{count}=@whole+@whole_account+@whole_out_firm+@whole_firm+@whole_date;
    $params->{whole_list}=\@whole;
    $params->{account_list}=\@whole_account;
    $params->{out_firm_list}=\@whole_out_firm;
    $params->{firm_list}=\@whole_firm;
    $params->{date_list}=\@whole_date;
    

   $field->{extended_value}=$self->template_proto_list($params);
   return $val;
    
}


sub setup
{
  my $self = shift;

   
  $self->start_mode('list');
  $self->run_modes(
    'AUTOLOAD'=>'list',
    'list' => 'list',
    'add'=>'add',
    'ajax_del_doc_trans'=>'ajax_del_doc_trans',
    'add_many'=>'add_many',
    'add_many_do'=>'add_many_do'
  );
}


sub get_right
{       
        my $self=shift;
	return 'docs';
}
sub add_many
{
	my $self=shift;
	
	#shift @{$proto->{fields}->[3]->{titles} };
        #unshift @{$proto->{fields}->[3]->{titles} },{"value"=>'', "title"=>"НЛО"};
        #shift @{$proto->{fields}->[2]->{titles} };
        #unshift @{$proto->{fields}->[2]->{titles} },{"value"=>'', "title"=>"Новая"};

	$self->{tpl_vars}->{out_firms}=get_normal_out_firms();
	$self->{tpl_vars}->{firms}=get_operators_firms($self->{user_id});
	$self->{tpl_vars}->{accounts}=get_accounts_income();
	my $tmpl=$self->load_tmpl('add_many_docs.html');
	my $output='';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;

}
sub add_many_do
{
	my $self=shift;
	my %params;
	map {$params{$_}= $self->query->param($_) }$self->query->param();
	my %q;
	$q{dt_fid}=$params{dt_fid};
	$q{user_id}=$self->{user_id};
	$q{dt_date}=$params{dt_date};
	for(my $i=0;$i<$params{number};$i++)
	{
		
		
		$q{dt_ofid}=$params{'dt_ofid'.$i};
		$q{dt_aid}=$params{'dt_aid'.$i};
		$q{dt_amnt}=$params{'dt_amnt'.$i};
		
		add_transaction_document(\%q);
			
			
			
	}
	
	$self->header_type('redirect');
	return $self->header_add(-url=>'?');
	


}
sub list
{
	my $self = shift;

	$proto->{'extra_where'}="dt_status='created' AND of_oid=".$self->{user_id};
	$proto->{ 'extra_where2'}="dt_status='processed' AND of_oid=".$self->{user_id};
	return $self->proto_list($proto);
}
sub add
{
	my $self = shift;
	$proto->{table}='documents_transactions';
    
	
	shift @{$proto->{fields}->[4]->{titles} };
        unshift @{$proto->{fields}->[4]->{titles} },{"value"=>'', "title"=>"НЛО"};
        shift @{$proto->{fields}->[2]->{titles} };
        unshift @{$proto->{fields}->[2]->{titles} },{"value"=>'', "title"=>"Новая"};

	return $self->proto_add_edit('add', $proto);

}

sub proto_add_edit_trigger{
  	
	my $self=shift;
  	my $params = shift;
	my %q;
	map { $q{$_}=$self->query->param($_) } $self->query->param();

	if($params->{method} eq 'add'&&$params->{step} eq 'operation')
	{
		$dbh->do($params->{sql});

	}elsif($params->{step} eq 'before'&&$params->{method} eq 'add')
	{
		
		$self->query->param('dt_oid',$self->{user_id});
		
	
		
		$q{dt_amnt}=~s/[,]/\./g;

		$q{dt_amnt}=~s/[ ]//g;

		die "Неправильный формат суммы \n" unless($q{dt_amnt}*1);
		$self->query->param('dt_amnt',$q{dt_amnt});

        die "Неправильный формат даты \n" if(!$q{dt_date}=~/\d\d\d\d-\d\d-\d\d/);


		die "Такого клиента нет \n"	if($q{dt_aid}&&!$dbh->selectrow_array(q[SELECT 
		a_id FROm accounts WHERE a_id=?],undef,$q{dt_aid}));

		    my $sql = qq[SELECT * FROM firms_out_operators
			WHERE 
			f_status='active' AND f_id=? AND o_id=?
			ORDER BY f_name 
			];

       	 	my $sth =$dbh->selectrow_hashref($sql,undef,$q{dt_fid},$self->{user_id});
		
		die "У вас нет такой фирмы \n" unless($sth->{f_id});
		
		$self->query->param('dt_comment','приходные документы')	unless($q{dt_comment});

		$self->query->param('dt_infl','no');

		$self->query->param('dt_status','created');
    
       my $of_id_=$self->query->param('dt_ofid');
       

       my $okpo=$self->query->param('dt_okpo');
       $okpo =~ /\d{8,10}/;
       die "Код ОКПО должен быть в формате 8-10 значного числа! \n" if((!($okpo =~ /\d{8}/) || length($okpo)<$OKPO_MIN || length($okpo)>$OKPO_MAX)&&!$of_id_*1);
	   my %tmp_okpo;
	   my @tmp_okpo_arr = split(//,$okpo);
       
       foreach my $var(@tmp_okpo_arr)
       {
       	   $tmp_okpo{$var}++;
       }
       
       die "Код ОКПО должен содердать хотя бы 3 разных цифры" if(scalar keys %tmp_okpo<3);
       
       die "У фирмы покупателя не обнаружен  код ОКПО ! \n"    if(!($of_id_*1)&&!$okpo);

        my $of_id=$dbh->selectrow_array(q[SELECT of_id FROM out_firms 
        WHERE of_id=? OR of_name=? OR of_okpo=?],undef,$of_id_,$of_id_,$okpo);

        die "Введите фирму покупателя \n" unless($of_id_);

		unless($of_id)
		{
            
            $dbh->do(q[INSERT INTO out_firms(of_name,of_okpo,of_oid) VALUES(ltrim(?),?,?)],undef,$of_id_,$okpo,$self->{user_id});
            $q{'dt_ofid'}=$dbh->selectrow_array(q[SELECT last_insert_id() ]);			
			$self->query->param('dt_ofid',$dbh->selectrow_array(q[SELECT last_insert_id() ]));
            

		}else
		{
			$self->query->param('dt_ofid',$of_id);
			$q{dt_ofid}=$self->query->param('dt_ofid');

		}

	
		if($q{dt_aid})
		{
			my ($id,$sum)=$dbh->selectrow_array(q[SELECT 
				dr_id,dr_amnt 
				FROM documents_requests 
				WHERE 
				dr_status='created' 
				AND dr_fid=? 
				AND dr_ofid_from=? 
				AND dr_aid=?
				AND dr_currency=? 
				AND MONTH(dr_date)=MONTH(?) AND YEAR(dr_date)=YEAR(?)
			],undef,$q{dt_fid},$q{dt_ofid},$q{dt_aid},'UAH',$q{dt_date},$q{dt_date});
		    my $percent=0;
            $percent=get_doc_pecent($q{dt_aid},$q{dt_date}) if ($q{dt_aid});
# 			$percent=1.2 unless($percent);

			unless($id)
			{
				$dbh->do(qq[INSERT INTO documents_requests
				(dr_comis,dr_aid,dr_amnt,dr_comment,dr_fid,dr_ofid_from,dr_oid,dr_date)
				VALUES($percent,?,?,?,?,?,?,?)
				],
				undef,$q{dt_aid},$q{dt_amnt},
				$self->query->param('dt_comment'),$q{dt_fid},$q{dt_ofid},$self->{user_id},$q{dt_date});
				my $doc_id=$dbh->selectrow_array(q[SELECT last_insert_id()]);
				$dbh->do(qq[INSERT INTO documents_payments(dp_ctid,dp_drid,dp_tid) VALUES(?,?,?)],undef,0,$doc_id,0);
				
				$dbh->do(
				qq[INSERT INTO documents_requests_logs
				(dr_comis,dr_aid,dr_amnt,dr_comment,dr_fid,dr_ofid_from,dr_oid,dr_date)
				VALUES($percent,?,?,?,?,?,?,?)
				],undef,$q{dt_aid},$q{dt_amnt},$self->query->param('dt_comment'),$q{dt_fid},$q{dt_ofid},$self->{user_id},$q{dt_date});
				$self->query->param('dt_drid',$doc_id);
				$self->query->param('dt_infl','yes');


			
			}else{
	
				my $sum_fact=$dbh->selectrow_array(q[SELECT sum(dt_amnt) 
				FROM 
				documents_transactions 
				WHERE 
                dt_drid=?  
				AND (dt_status='created' 
				OR  dt_status='processed')
				],undef,$id);
								
				$sum_fact+=$q{dt_amnt};
               
				

				
				my $payd_sum=$dbh->selectrow_array(q[SELECT  
                                    dr_amnt*(sum(t_amnt)/(dr_comis*(dr_amnt/100))) as payd_sum 
								     FROM 
								     documents_payments,transactions,documents_requests
								     WHERE dp_tid=t_id 
								     AND dr_id=dp_drid 
                                     AND dr_id=? GROUP BY dr_id],undef,$id);

				$self->query->param('dt_status','processed') if($payd_sum>=$sum_fact);
				if($sum_fact>$sum)
				{
					$dbh->do(q[UPDATE documents_requests SET dr_amnt=?  WHERE dr_id=?],undef,$sum_fact,$id);
					$self->query->param('dt_infl','yes');

				}
			
				$self->query->param('dt_drid',$id);
			
			}
			
		}


		
	
	}


}

	



1;
