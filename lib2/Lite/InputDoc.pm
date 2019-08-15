package Lite::InputDoc;
use strict;
use base 'CGIBaseLite';
use SiteConfig;
use SiteDB;
use SiteCommon;
$SIG{__DIE__}=\&handle_errors;

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
		INCLUDE_PATH => $DIR_LITE,
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
#our $DOCUMENTS=1;
my $proto={
  'table'=>"cashier_transactions",  
  'template_prefix'=>"doc_in2",
  'page_title'=>'Выписки',
  'extra_where'=>q[ 1  AND  ct_amnt>0  AND ct_status='processed'  ],
  'id_field'=>'ct_id',
  'sort'=>' ct_date DESC',
  'need_confirmation'=>1,

  'fields'=>[
    {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1,filter=>'=','filter_invisible'=>'1'},
    {'field'=>"ct_date", "title"=>"Дата поступления", "no_add_edit"=>1,'filter'=>"time" },
    {'field'=>"ct_ts", "no_add_edit"=>1, "no_view"=>1, "title"=>"Дата", },
    {
	'field'=>"ct_fid", "title"=>"Фирма", "category"=>"firms", "no_add_edit"=>1, 'filter'=>"="
     , "type"=>"select"
    },    
    {
	'field'=>"ct_aid", "title"=>"Карточка", "category"=>"accounts"
	},
    {
	'field'=>"ct_fsid", "title"=>"Услуга", "category"=>"firm_services", "may_null"=>1,
    	java_script_action=>'onchange="change_services()"'
    },
    {'field'=>"ct_amnt", "title"=>"Сумма", "no_add_edit"=>1, 'filter'=>"=",},
    {'field'=>"ct_comis_percent", "title"=>"Процент комиссии",java_script_action=>'onkeyUp="change_commission()"',
   no_base=>0 },
	
    {'field'=>"commission", "title"=>"Сумма комиссии ",'default'=>"0",'system'=>1,"no_add_edit"=>1,no_base=>1},
    {'field'=>"common_sum", "title"=>"Общая сумма",'default'=>"0",'system'=>1,"no_add_edit"=>1,no_base=>1},	
    {'field'=>"ct_currency", "title"=>"Валюта", 'filter'=>"=", "type"=>"select"
     , "titles"=>\@currencies
     , "no_add_edit"=>1,},
    {'field'=>"ct_eid",'title'=>'Произвести обмен','system'=>1,"category"=>"exchange",'value'=>'ct'},	

    {'field'=>"ct_comment", "title"=>"Назначение", "no_add_edit"=>0,'filter'=>'like'},
    {
     'field'=>"ct_oid2", "title"=>"Оператор 2"
      , "no_add_edit"=>1, 
      ,"no_view"=>1, "category"=>"operators"
    },
    {'field'=>"ct_tid2", "title"=>"Транзакция 2"
      , "no_add_edit"=>1
      ,"no_view"=>1
    },
    {'field'=>"ct_tid2_comis", "title"=>"Транзакция 2, комиссия"
      , "no_add_edit"=>1
      ,"no_view"=>1
    },
    {'field'=>"ct_ts2", "title"=>"Дата занесения "
      , "category"=>'date'
     
    },
  ],
};

sub setup
{
  my $self = shift;
 #$SIG{__DIE__}=\&proto_die_catcher; 
#    'make_payment'  => 'make_payment',
  
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'make_payment_from_program'=>'make_payment_from_program'
 
  );
}
sub get_right
{       
        my $self=shift;
        return 'docs';
}
sub list
{
   	my $self = shift;

	my $params=$self->query->param('param');
	my @ar=split(/_/,$params);

	$self->query->param('a_id',$ar[1]);
	$self->query->param('ct_aid',$ar[1]);
	
	$self->query->param('ct_currency',$ar[2]);
	$self->query->param('ct_currency',$ar[2]);

   	
   	my $ct_currency=$self->query->param('ct_currency');

	$ar[1]=~s/["'\\]//g;
	##there must be checking
	$proto->{param}=$params;
	
	
	my $extr=qq[SELECT ct_id FROM documents_payments,cashier_transactions 
	WHERE  ct_aid=$ar[1] AND ct_id=dp_ctid ];
	$self->{tpl_vars}->{account_info}=get_account_name($ar[1]);

	$proto->{page_title}='Оплата приходов';
	$proto->{extra_where}.=" AND ct_aid=$ar[1] AND ct_currency='$ar[2]' AND  ct_id NOT IN ($extr) ";
   	return $self->proto_list($proto);
}
sub make_payment
{
	my $self = shift;
	my @ids=$self->query->param('ct_id');
	my $param=$self->query->param('param');
	map { $_=~s/["'\\]//g } @ids;
	my $stid=join(',',@ids);
	my @params=split('_',$param);
	map { $_=~s/["'\\]//g } @params;

	my $ref=$dbh->selectall_arrayref(qq[SELECT ct_amnt,ct_currency,ct_id
			FROM cashier_transactions 
			WHERE ct_aid=? 
			AND ct_status='processed' 
			AND ct_id IN ($stid) ],undef,$params[1]
			);

	my $sum=0;
	my @ct_id;
		
	my $purses={USD=>'a_usd',UAH=>'a_uah',EUR=>'a_eur'};


	my $dr_ids=$dbh->selectall_hashref(qq[SELECT 
		dr_id,sum(ct_amnt) as payed,dr_currency,dr_comis*(dr_amnt/100) as sum_somis,
		dr_comis*(dr_amnt/100)-sum(t_amnt) as last_sum,a_usd,a_uah,a_eur
		FROM
		documents_requests,
		transactions,
		documents_payments,
		accounts  
		WHERE dp_tid=t_id 
		AND dr_id=dp_drid  
		AND dr_aid=a_id
		AND dr_aid=$params[1] 
		AND dr_status='created'
		AND dr_fid=$params[0] 
		AND  dr_currency='$params[2]'
		AND dr_ofid_from=$params[3] GROUP BY dr_id],'dr_id');
	
	my $ost_tok={ct_amnt=>0,ct_id=>0,fin=>1};
	my @keys=sort keys %$dr_ids;
	
	die "Не хватает средств для оплаты  \n"	if($dr_ids->{$params[1]}->{$purses->{ $dr_ids->{$params[1]}->{dr_currency} } }<$dr_ids->{$params[1]}->{last_sum});

	my $sum;
	my $key;	
	my $sql=q[INSERT INTO documents_payments(dp_drid,dp_ctid,dp_tid) VALUES];
	my $sum_all=0;
	
	
		foreach(@$ref)
		{
			
			if($ost_tok->{fin})
			{
				$ost_tok->{ct_amnt}=$_->[0];
				$ost_tok->{ct_id}=$_->[2];
				$ost_tok->{fin}=1;
			}
			$key=$keys[0];

			last unless($key);
			
			$sum=($dr_ids->{$key}->{last_sum}>=$ost_tok->{ct_amnt} and $dr_ids->{$key}->{last_sum}-=$ost_tok->{ct_amnt} and $ost_tok->{fin}=1  and $ost_tok->{ct_amnt});

			unless($sum)
			{
				$sum=$dr_ids->{$key}->{last_sum};
				shift @keys;
				delete $dr_ids->{$key}; 
			}
			my $tid=$self->add_trans(
			{
				t_status=>'system',
				t_amnt=>$sum,
				t_currency=>$_->[1],
				t_name1 => $params[1] ,
				t_name2 => $DOCUMENTS,
				t_comment => "Оплата прихода #$key с #$ost_tok->{ct_id}",
			}
			);
			$sum_all+=$sum;
			$sql.=qq[($key,$ost_tok->{ct_id},$tid),];
			
		}
	
	chop($sql);
	$dbh->do($sql) if(@$ref);
	
	
	return $self->ok({sum=>$sum_all,key_field=>$param});

}
sub make_payment_from_program
{
	my $self = shift;
	my $param=$self->query->param('param');
	my @params=split('_',$param);
	map { $_=~s/["'\\]//g } @params;

		
	my $sum=0;
	my @ct_id;
	

	my $dr_ids=$dbh->selectrow_hashref(qq[SELECT 
		dr_id,sum(t_amnt) as payed,dr_comis*(dr_amnt/100) as sum_somis,
		dr_currency,
		dr_comis*(dr_amnt/100)-sum(t_amnt) as last_sum,
		a_usd,
		a_uah,
		a_eur
		FROM
		documents_requests,
		transactions,
		documents_payments,
		accounts
		WHERE dp_tid=t_id 
		AND dr_id=dp_drid  
		AND dr_aid=$params[1] 
		AND dr_status='created'
		AND dr_aid=a_id
		AND dr_fid=$params[0] 
		AND dr_currency='$params[2]'
		AND dr_ofid_from=$params[3] GROUP BY dr_id]);

	
	my $sql=q[INSERT INTO documents_payments(dp_drid,dp_ctid,dp_tid) VALUES];

	my $key=$dr_ids->{dr_id};

	my $purses={USD=>'a_usd',UAH=>'a_uah',EUR=>'a_eur'};
		


	if(1||($dr_ids->{last_sum}&&$dr_ids->{ $purses->{ $dr_ids->{dr_currency} } }>$dr_ids->{last_sum}))
	{
			my $tid=$self->add_trans(
			{
				t_status=>'system',
				t_amnt=>$dr_ids->{last_sum},
				t_currency=>$dr_ids->{dr_currency},
				t_name1 => $params[1] ,
				t_name2 => $DOCUMENTS,
				t_comment => "Оплата прихода #$key со счета клиента",
			}
			);
		$sql.=qq[($key,0,$tid)];

		$dbh->do($sql);

		$dbh->do(q[UPDATE documents_transactions SET dt_status='processed' WHERE dt_drid=?],undef,$key);

		return $self->ok({sum=>$dr_ids->{last_sum},key_field=>$param});

	}else	
	{
		die "Не хватает средств для оплаты  \n";

	
	}
}


sub ok
{
	my $self=shift;
	my $id=shift;
	
	my $tmpl=$self->load_tmpl('proto_ok_doc.html');
        my $output = "";
	$self->{tpl_vars}->{id}=$id->{key_field};
	$self->{tpl_vars}->{amnt}=$id->{sum};
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;


}




1;