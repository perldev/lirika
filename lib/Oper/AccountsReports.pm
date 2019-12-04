package Oper::AccountsReports;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
#    {'field'=>"ts", 'category'=>'date', "title"=>"Дата", 'filter'=>"time"},
use WorkingWindow;

my $proto;




sub setup
{
   my $self = shift;
#####
   
#  die  $self->query->param('do');
   $self->start_mode('list');




   $self->run_modes(
		'AUTOLOAD'   => 'list',
		'list' => 'list',
		'send_balance'=>'send_balance',
# 		'credit'=>'credit',
# 		'get_credit'=>'get_credit',
# 		'print'=>'print',
# 		'export_excel'=>'export_excel',
# 		'archive'=>'archive',
# 		'search_in_ahrchive'=>'search_in_ahrchive',
# 		'send_through_localhost'=>'send_through_localhost',
# 		'restore_archive'=>'restore_archive',
# 		'document_list_uah'=>'document_list_uah'
 	);
}



sub restore_archive{

    my $self=shift;
    my $id=$self->query->param('ct_aid');
    my $new_aid=WorkingWindow::restore_working_window($id);
    $self->header_type('redirect');
    return $self->header_add(-url=>"?do=list&ct_date=all_time&action=filter&ct_aid=$id");
    

}


sub search_in_ahrchive
{
    my $self=shift;
    die "not implemented";

    my $ts=$self->query->param('ts1');
    my $ts2=$self->query->param('ts2');
    my $ct_aid=$self->query->param('ct_aid');
    
    $ts=~s/[^\d:-]//g;
    $ts2=~s/[^\d:-]//g;


    $proto->{del_to}=0;

    my $start_amnts;
    if($ct_aid) 
    {

        my $ref=$dbh->selectrow_hashref(q[SELECT * FROM accounts WHERE a_id=?],undef,$ct_aid);  
                


        map { $proto->{$_}=format_float($ref->{$_}) } keys %$ref;
        
        $proto->{a_name}=$ref->{a_name};

        my $sums=calculate_sum_with(
                {
                    a_id=>$ct_aid,
                    date2=>" 1 ",
                    date1=>"  ts>'$ts' ",
                    table=>'accounts_reports_table_archive'
                }
                );

        my $sums1=calculate_sum_with(
                {
                    a_id=>$ct_aid,
                    date2=>" 1 ",
                    date1=>"  ts>'$ts' ",
                    table=>'accounts_reports_table'
                }
                );

        $proto->{'extra_where'}=qq[ ct_status!='deleted' AND ts>'$ts' AND ts<'$ts2' ];
        $proto->{table}=q[accounts_reports_table_archive];

        $proto->{beg_uah}=($ref->{a_uah}-$sums1->{UAH})-$sums->{UAH};

        $proto->{beg_usd}=($ref->{a_usd}-$sums1->{USD})-$sums->{USD};#$ref->{a_usd}-$from->{USD};

        $proto->{beg_eur}=($ref->{a_eur}-$sums1->{EUR})-$sums->{EUR};

        
        $proto->{orig__beg_uah}=$proto->{beg_uah};

        $proto->{orig__beg_usd}=$proto->{beg_usd};

        $proto->{orig__beg_eur}=$proto->{beg_eur};
    
        $proto->{beg_uah}=format_float($proto->{beg_uah});
        $proto->{beg_usd}=format_float($proto->{beg_usd});
        $proto->{beg_eur}=format_float($proto->{beg_eur});

        $proto->{from_date}=format_date($ts);
        $proto->{to_date}=format_date($ts2);
        
        $proto->{reports_rate}=$dbh->selectall_hashref(qq[SELECT 
                        rr_rate,rr_date
                        FROM reports_rate 
                        WHERE 
                        rr_date>='$ts' AND 
                        rr_date<='$ts2'],'rr_date');
        
    }   
       


    
    $proto->{checked_all}=$dbh->selectrow_array(q[SELECT count(*) FROM accounts_reports_table_archive WHERE ct_status!='deleted' AND ct_aid=?],undef,$ct_aid)==$dbh->selectrow_array(q[SELECT count(*) FROM accounts_reports_table WHERE ct_status!='deleted' AND col_status='yes' AND ct_aid=?],undef,$ct_aid);

     $proto->{'info'}=get_client_oper_info($ct_aid);
     


         $proto->{'ct_aid'}=$ct_aid;
         $proto->{'sort'}=' ts ASC';
     my %hash;
    
    $proto->{sums}=\%hash;      
        
    return $self->proto_list($proto,{fetch_row=>\&sum,after_list=>\&last_record});
    


}
sub archive
{
	my $self=shift;
	my $id=$self->query->param('ct_aid');
        my $ts=$self->query->param('to_ts');
        die "not implemented";



	my $new_aid=WorkingWindow::save_working_window($id,$ts,$self->{user_id});
	$self->header_type('redirect');
	return $self->header_add(-url=>"?do=list&ct_date=all_time&action=filter&ct_aid=$id");
} 

###not used now , use unify_export_excel
sub export_excel
{
	my $self=shift;
	die "not implemented";

	my $id=$self->query->param('ct_aid');
	my ($email,$now,$passwd)=$dbh->selectrow_array('SELECT 
		a_email,to_days(NOW()),a_report_passwd FROM accounts WHERE a_id=?',undef,$id);
	my $fid=$id;
 	$proto->{'ct_aid'}=$fid;
	$proto->{'sort'}=' ts ASC';
	my %hash;
	$proto->{sums}=\%hash;		
	
	$self->{no_script}=1;
	$self->{no_header_menu}=1;
	$proto->{no_formating}=1;
	
	$self->list($proto);
	unlink("../data/excel/$id"."_$now.xls");
	$self->built_excel($self->{tpl_vars}->{rows},">../data/excel/$id"."_$now.xls") or die $!;
	my $file="excel/$id"."_$now.xls";
	return $file;
	
}
sub print
{
	my $self=shift;
	my $fid=$self->query->param('ct_aid');
        die "not implemented";

 	if($fid)	
 	{
 		my $ref=$dbh->selectrow_hashref(q[SELECT * FROM accounts WHERE a_id=?],undef,$fid);	
		map { $proto->{$_}=format_float($ref->{$_}) } keys %$ref;
		$proto->{a_name}=$ref->{a_name};
		my @filter_where;

        my $row=$dbh->selectrow_array(q[SELECT ah_ts FROM accounts_history 
        WHERE ah_aid=? AND ah_status!='deleted'  ORDER BY ah_id DESC LIMIT 1],undef,$fid);    
    

        my @filter_where;
        push @filter_where,$row if($proto->{table} eq 'accounts_reports_table');
        $filter_where[0]='0000-00-00 00:00:00' unless($filter_where[0]);
        

        my $sums=calculate_sum_with(
                {
                    a_id=>$fid,
                    date_from=>$filter_where[0],
                    date_to=>$filter_where[1],
                    date2=>" 1 ",
                    date1=>' 1 ',   
                    table=>$proto->{table}
                }
                );


        
#       use Data::Dumper;
#           die Dumper $sums;

        
        $proto->{beg_uah}=$ref->{a_uah}-$sums->{UAH};

        $proto->{beg_usd}=$ref->{a_usd}-$sums->{USD};#$ref->{a_usd}-$from->{USD};

        $proto->{beg_eur}=$ref->{a_eur}-$sums->{EUR};


        
        $proto->{orig__beg_uah}=$proto->{beg_uah};
        $proto->{orig__beg_usd}=$proto->{beg_usd};
        $proto->{orig__beg_eur}=$proto->{beg_eur};




		$proto->{beg_uah}=format_float($proto->{beg_uah});
  		$proto->{beg_usd}=format_float($proto->{beg_usd});
  		$proto->{beg_eur}=format_float($proto->{beg_eur});

		$proto->{from_date}=format_date($filter_where[0]);
 		$proto->{to_date}=format_date($filter_where[1]);
 		$proto->{reports_rate}=$dbh->selectall_hashref(qq[SELECT 
						rr_rate,rr_date
						FROM reports_rate 
		 				WHERE 
						rr_date>='$filter_where[0]' AND 
						rr_date<='$filter_where[1]'],'rr_date');
 		
 	}	
	   


 	
	$proto->{checked_all}=$dbh->selectrow_array(q[SELECT count(*) FROM accounts_reports_table WHERE ct_status!='deleted' AND ct_aid=?],undef,$fid)==$dbh->selectrow_array(q[SELECT count(*) FROM accounts_reports_table WHERE ct_status!='deleted' AND col_status='yes' AND ct_aid=?],undef,$fid);


    $proto->{'info'}=get_client_oper_info($fid);

	$proto->{'template_prefix'}="accounts_reports_print";

	$proto->{'ct_aid'}=$fid;
	$proto->{'sort'}=' ts ASC';
	my %hash;
	$proto->{sums}=\%hash;		
        $proto->{'extra_where'}=q[ ct_status!='deleted' ]; 
   	$self->{no_header_menu}=1;
	$self->{no_script}=1;
	$self->{user_id}=undef;

	return $self->proto_list($proto,{fetch_row=>\&sum,after_list=>\&last_record});


}

sub get_credit
{
	my $self=shift;
	my %params;
        die "not implemented";

	map {$params{$_}=$self->query->param($_) } $self->query->param();
    
    return $self->error("Вы не выбрали валюту \n")     unless($conv_currency->{$params{currency}});
	return $self->error( "Нет начальной даты \n")	unless($params{from_ts});
	return $self->error("Нет конечной даты \n")	unless($params{to_ts});
	
	return $self->error( "На этот период уже кредит есть \n ") if($dbh->selectrow_array(q[SELECT 
	c_id FROM credits WHERE 
	c_aid=?  AND c_currency=? AND	((c_start<=? AND c_finish>=?) OR (c_start<=? AND c_finish>=?))
	 ],undef,$params{ct_aid},$params{currency},$params{from_ts},$params{from_ts},$params{to_ts},$params{to_ts}));


	my $tid=$self->add_trans({
			t_name1 => $params{ct_aid},
			t_name2 =>$credit_id ,
			t_currency =>$params{currency},
            t_amnt => abs($params{'sum'}),
			t_comment => $params{'comment'},
		}

	);



	$dbh->do(q[INSERT INTO accounts_transfers SET at_tid=?],undef,$tid);
	my $atid=$dbh->selectrow_array(q[SELECT last_insert_id()]);

	$dbh->do(qq[
		INSERT INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
		select 
		t_id,
		`transactions`.`t_aid2` AS `t_aid2`,
		`transactions`.`t_comment` AS	`t_comment`,
		`operators`.`o_id` AS `o_id`,`operators`.`o_login` AS `o_login`,
		`transactions`.`t_aid1` AS 
		`t_aid1`,`accounts`.`a_name` AS `a_name`,`transactions`.`t_amnt` AS 
		`t_amnt`,`transactions`.`t_currency` 
		 AS `t_currency`,
		0 AS `0`,
		`transactions`.`t_amnt` AS `t_amnt`,
		0 AS `0`,
		0 AS `0`,
		'$params{to_ts}' AS `t_ts`,
		`transactions`.`t_currency` AS `t_currency`,
		0 AS `0`,
		0 AS `0`,'transaction' AS `transaction`,
		'$params{to_ts}' AS `ts`,
		'0000-00-00 00:00:00',
		`transactions`.`del_status` AS `del_status`,
		16777215  
		from ((`transactions` join `operators`) join `accounts`) 
		WHERE (1 and (`operators`.`o_id` = `transactions`.`t_oid`) 
		and (`accounts`.`a_id` = `transactions`.`t_aid1`))
		AND t_id=?
	
	],undef,$tid);
	$dbh->do(qq[
		INSERT INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
		select 
		t_id,
		`transactions`.`t_aid1` AS `t_aid1`,
		`transactions`.`t_comment` AS `t_comment`,
		`operators`.`o_id` AS `o_id`,
		`operators`.`o_login` AS `o_login`,
		`transactions`.`t_aid2` AS `t_aid2`,
		`accounts`.`a_name` AS `a_name`,
		-(`transactions`.`t_amnt`) AS `-t_amnt`,
		`transactions`.`t_currency` AS `t_currency`,
		0 AS `0`,
		-(`transactions`.`t_amnt`) AS `-t_amnt`,
		0 AS `0`,0 AS `0`,
		'$params{to_ts}' AS `t_ts`,
		`transactions`.`t_currency` AS `t_currency`,0 AS `0`,0 AS `0`,
		'transaction' AS `transaction`,
		'$params{to_ts}' AS `ts`,
		'0000-00-00 00:00:00',
		`transactions`.`del_status` AS `del_status`,
		16777215  
		from 
		((`transactions` join `operators`) join `accounts`) 
		where (1 and (`operators`.`o_id` = `transactions`.`t_oid`) 
		AND (`accounts`.`a_id` = `transactions`.`t_aid2`))
		AND t_id=?
	
	],undef,$tid);



	$dbh->do(q[INSERT INTO
	 credits(c_start,c_finish,c_aid,c_tid,c_amnt,c_currency,c_percent,c_oid,c_comment)
	VALUES(?,?,?,?,?,?,?,?,?)
	],undef,$params{from_ts},$params{to_ts},$params{ct_aid},$tid,
	abs($params{'sum'}),
	$params{currency},
	$params{'percent'},$self->{user_id},"Выплаты по кредиту");
	$self->header_type('redirect');
	return	
	 $self->header_add(-url=>"?do=list&action=filter&ct_date=all_time&ct_aid=$params{ct_aid}");
}
sub credit
{
	my $self=shift;
        die "not implemented";

	my $fid=$self->query->param('ct_aid');
	my $percent=$self->query->param('percent');
	my $currency=$self->query->param('currency');
    $proto->{credit_currency}=$currency;
    $proto->{credit_currency}='USD' unless($conv_currency->{ $proto->{credit_currency} });


	$proto->{table}='accounts_reports_table';
	$proto->{del_to}=0;

 	if($fid)	
 	{
 		my $type=$self->query->param('type_time_filter');
 		my $ref=$dbh->selectrow_hashref(q[SELECT * FROM accounts WHERE a_id=?],undef,$fid);	

   	       $proto->{'extra_where'}=q[ ct_status!='deleted' ];

		map { $proto->{$_}=format_float($ref->{$_}) } keys %$ref;

		$proto->{a_name}=$ref->{a_name};
			
		
			my @filter_where;
 		
 			my $row1={};
 			my $from=$self->query->param('ts_from');
 			my $to=$self->query->param('ts_to');
 			push @filter_where,$from;
 			push @filter_where,$to;
 		
		
		
		my $sums=calculate_sum_with(
				{
					a_id=>$fid,
					date_from=>$filter_where[0],
					date_to=>$filter_where[1],
					date2=>" 1 ",
					date1=>"ts>'$filter_where[0]'",
				}
				);
		
	

		
 		$proto->{beg_uah}=$ref->{a_uah}-$sums->{UAH};
  		$proto->{beg_usd}=$ref->{a_usd}-$sums->{USD};#$ref->{a_usd}-$from->{USD};
  		$proto->{beg_eur}=$ref->{a_eur}-$sums->{EUR};
		$proto->{orig__beg_uah}=$proto->{beg_uah};
  		$proto->{orig__beg_usd}=$proto->{beg_usd};
  		$proto->{orig__beg_eur}=$proto->{beg_eur};
	
		$proto->{beg_uah}=format_float($proto->{beg_uah});
  		$proto->{beg_usd}=format_float($proto->{beg_usd});
  		$proto->{beg_eur}=format_float($proto->{beg_eur});

		$proto->{from_date}=format_date($filter_where[0]);
 		$proto->{to_date}=format_date($filter_where[1]);
   	        $proto->{beg_calc_date}=$filter_where[0];
   		$proto->{fin_calc_date}=$filter_where[1];
		
 		$proto->{reports_rate}=$dbh->selectall_hashref(qq[SELECT 
						rr_rate,rr_date
						FROM reports_rate 
		 				WHERE 
						rr_date>='$filter_where[0]' AND 
						rr_date<='$filter_where[1]'],'rr_date');
 		
 	}	

   $proto->{'ct_aid'}=$self->query->param('ct_aid');
   $proto->{'sort'}=' ts ASC';

   my %hash;

   $proto->{sums}=\%hash;	
   $proto->{credit}={comment=>"Кредит с $proto->{from_date} по $proto->{to_date}",
			percent=>$percent,sum=>0,day_percent=>($percent/100)/30};
 
   push @{ $proto->{fields} },{'field'=>'ts','filter'=>'time'};

   return $self->proto_list($proto,{fetch_row=>\&sum_credit,after_list=>\&last_record_credit});
	


}

sub send_balance
{
	my $self=shift;
        die "not implemented";

	my $id=$self->query->param('ct_aid');
	my $own_email=$self->query->param('email');
	$proto->{table}='accounts_reports_table';
	my ($email,$now,$passwd,$a_name)=$dbh->selectrow_array('SELECT 
		a_email,to_days(NOW()),a_report_passwd,a_name FROM accounts WHERE a_id=?',undef,$id);
	
	$passwd=trim($passwd);
        die "there is no $id \n" unless($id);
        

	if(!$email&&!$own_email){

		die "there isn't mail for a_id $id \n";
		 	
	}
        
        die "there is no passwd \n" unless(trim($passwd));
 	die "there is no such user \n" unless(trim($a_name));

	my $fid=$id;
 	$self->query->param('action','filter');		
   
	$proto->{'ct_aid'}=$fid;
	$proto->{'sort'}=' ts ASC';
	my %hash;
	$proto->{sums}=\%hash;		
	


	  my $file="/tmp/$id"."_$now.xls";
          my $file2="/tmp/$id"."_$now.html"; 
	  my $file1="/tmp/$id"."_$now.rar";

	  unlink("$file1");
	  unlink("$file2");
	  unlink("$file");

##############
	

	$self->{no_script}=1;
	$self->{no_header_menu}=1;

	$proto->{'template_prefix'}="accounts_reports_send";

	$proto->{mail}=1;

	my $txt=$self->list($proto);

	open(FL,">/tmp/$id"."_$now.html") or die $!;
	print FL $txt;
	close(FL);

	
	$self->{tpl_vars}->{rows}=[];
	$proto->{no_formating}=1;
	
	$self->list($proto);

	$self->built_excel($self->{tpl_vars}->{rows},">/tmp/$id"."_$now.xls ") or die $!;
	
	
	system("rar a -hp$passwd $file1 $file2 $file > /dev/null");
		

	
	my @mails;
	require Encode;
        Encode::from_to($a_name,'cp1251','utf8');
	unless($own_email)
	{
		@mails=split(/,/,$email);

		map {send_mail({file=>"$file1",mail_to=>$_,a_name=>$a_name} ) } @mails ;

	}else
	{
		send_mail({file=>"$file1",mail_to=>$own_email,a_name=>$a_name} );
	}
	return 'ok!' if($self->query->param('ajax'));
	    
	$self->header_type('redirect');
	return $self->header_add(-url=>'?');
	

}
sub built_excel
{
	my ($self,$rows,$file)=@_;
	die "not implemented";
	require Spreadsheet::WriteExcel::Simple;
	my $ss = Spreadsheet::WriteExcel::Simple->new;
	my @headings=('Дата' ,'Б/н приход(ГРН)','% Комиссия','Комиссия','Доп.ком','Итого (ГРН)','Курс','Итого (USD)','Итого (EUR)','Касса ГРН','Касса USD','Касса EUR','Б/н вал. отправки','Примечания','От кого');
	map {	$_=my_decode($_) } @headings;
	$ss->write_bold_row(\@headings);
	my $mines;
	 #use Data::Dumper;
	#die Dumper $rows;
	
	foreach(@{$rows})
	{	
	


	($mines,$_->{rate})=$self->calculate_exchange(0,$_->{rate},$_->{orig__ct_currency},$_->{e_currency2}) if($_->{ct_ex_comis_type} eq 'simple'&&$_->{ct_eid});

        ($mines,$_->{rate})=$self->calculate_exchange(0,$_->{rate},$_->{e_currency2},$_->{orig__ct_currency}) if($_->{ct_ex_comis_type} ne 'simple'&&$_->{ct_eid});





	$_->{rate}=POSIX::ceil($_->{rate}*10000)/10000;	

	$mines=1;
	$mines=-1 if($_->{orig__ct_amnt}<0);		
		if($_->{ct_ex_comis_type} eq 'concl')
		{ 
			my @a=('',my_decode('Итого на:'),'',my_decode($_->{ct_date}),
			'',
			$_->{UAH},'',$_->{USD},$_->{EUR},
			'',
			'',
			'',
			'',
			'',
			'');
			$ss->write_row(\@a);
			next;
		}
		if($_->{ct_ex_comis_type} eq 'transaction')
		{	
			$_->{ct_date}=format_date($_->{ct_date});	
			my @a=(my_decode($_->{ct_date}),'',
			$_->{ct_comis_percent},
			$_->{comission},
			$_->{ct_ext_commission}?$_->{ct_ext_commission}:undef,
			$_->{orig__ct_currency} eq 'UAH'?$_->{ct_amnt}:undef,
			'',
			$_->{orig__ct_currency} eq 'USD'?$_->{ct_amnt}:undef, 
			$_->{orig__ct_currency} eq 'EUR'?$_->{ct_amnt}:undef,
			'',
			'',
			'',
			'',
			my_decode($_->{ct_comment}),
			my_decode("$_->{f_name}(#$_->{orig__ct_fid})"));
			
			$ss->write_row(\@a);	
			next;
			
		}
		if($_->{orig__ct_fid}>0&&$_->{orig__ct_currency} ne 'UAH')
		{	
			
			
			$_->{ct_date}=format_date($_->{ct_date});
			my @a=($_->{ct_date},'',
			$_->{ct_comis_percent},
			$_->{comission},
			$_->{ct_ext_commission}?$_->{ct_ext_commission}:undef,
			$_->{e_currency2} eq 'UAH'?$mines*$_->{result_amnt}:undef,
			$_->{rate},
			$_->{e_currency2} eq 'USD'?$mines*$_->{result_amnt}:undef,
			$_->{e_currency2} eq 'EUR'?$mines*$_->{result_amnt}:undef, 
			'',
			'',
			'', 
			my_decode("$_->{ct_amnt} $_->{ct_currency}"),
			my_decode($_->{ct_comment}),
			my_decode("$_->{f_name}(#$_->{orig__ct_fid})"));
# 			die Dumper \@a;
			$ss->write_row(\@a);	
			next;
	
		}
		if($_->{orig__ct_fid} >0)
		{	
			$_->{ct_date}=format_date($_->{ct_date});
			my $orig = $_->{orig__ct_currency}; 
			my $exch = $_->{e_currency2}; 
			my @a=($_->{ct_date},
			$orig eq 'UAH'?$_->{ct_amnt}:undef,
			$_->{ct_comis_percent},
			$_->{comission},
			$_->{ct_ext_commission}?$_->{ct_ext_commission}:undef,
			$_->{ct_eid}&&$exch eq 'UAH'||(!$_->{ct_eid}&&$orig eq 'UAH')?$_->{result_amnt}:undef,
			$_->{ct_eid}?$_->{rate}:undef, 
			$_->{ct_eid}&&$exch eq 'USD'?$mines*$_->{result_amnt}:undef,
			$_->{ct_eid}&&$exch eq 'EUR'?$mines*$_->{result_amnt}:undef,
			'',
			'',
			'', 
			$_->{orig__ct_currency} ne 'UAH'?my_decode($mines*$_->{result_amnt}.' '.$_->{ct_currency}):undef,
			my_decode($_->{ct_comment}),
			my_decode("$_->{f_name}(#$_->{orig__ct_fid})"));
			$ss->write_row(\@a);
			next;	
		}	
		if($_->{orig__ct_fid} <0 && $_->{orig__ct_fid}!=-2)
		{
=pod
    $_->{e_currency2} eq 'UAH'?$mines*$_->{result_amnt}:undef,
            $_->{rate},
            $_->{e_currency2} eq 'USD'?$mines*$_->{result_amnt}:undef,
            $_->{e_currency2} eq 'EUR'?$mines*$_->{result_amnt}:undef, 
=cut
			$_->{ct_date}=format_date($_->{ct_date});
			my @a=(my_decode($_->{ct_date}),
			'',
			$_->{ct_comis_percent},
			$_->{comission},
			$_->{ct_ext_commission},
			$_->{ct_currency} eq 'UAH'?$_->{result_amnt}:undef, 
			'',
			$_->{ct_currency} eq 'USD'?$_->{result_amnt}:undef,
			$_->{ct_currency} eq 'EUR'?$_->{result_amnt}:undef,
			$_->{orig__ct_currency} eq 'UAH'?$_->{orig__ct_amnt}:undef,
			$_->{orig__ct_currency} eq 'USD'?$_->{orig__ct_amnt}:undef, 
			$_->{orig__ct_currency} eq 'EUR'?$_->{orig__ct_amnt}:undef,
	
			'',
			my_decode($_->{ct_comment}),
			my_decode("$_->{f_name}(#$_->{orig__ct_fid})"));
			$ss->write_row(\@a);
			next;
		}
		
		if($_->{orig__ct_fid} ==-2)
		{
			$_->{ct_date}=format_date($_->{ct_date});
			my @a=(my_decode($_->{ct_date}),
			my_decode("$_->{ct_amnt} $_->{ct_currency}"),
			0.00,
			0.00,
			'',
			$_->{e_currency2} eq 'UAH'?$_->{result_amnt}:undef,
			$_->{rate},
			$_->{e_currency2} eq 'USD'?$_->{result_amnt}:undef,
			$_->{e_currency2} eq 'EUR'?$_->{result_amnt}:undef,	
			'',
			'',
			'', 
			'',
			my_decode($_->{ct_comment}),
			my_decode("$_->{f_name}(#$_->{orig__ct_fid})")
			);	
			$ss->write_row(\@a);
			next;
		} 	

  

	}
       $ss->save($file) or die $!;



}

sub get_right
{       
  #
    my $self=shift;
    my $fid=$self->query->param('ct_aid');
    die "<У вас нет доступа к данной карточке>\n" unless($dbh->selectrow_array(q[SELECT oaav_oid FROM operators_accounts_access_view WHERE oaav_oid=? AND oaav_aid=?],undef,$self->{user_id},$fid));
   
    $proto={
    'table'=>"accounts_reports_table",  
    'template_prefix'=>"accounts_reports",
    'page_title'=>"Выписка по клиентам",
    'sort'=>'id ASC ',
    'dates_comment'=>undef,
    'fields'=>[
        {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
      {'field'=>"ct_fid", "title"=>"Фирма", "category"=>"firms", 'filter'=>"="
        , "type"=>"select",
        },
        {'field'=>"ct_aid", "title"=>"Карточка",'type'=>'select',
        'filter'=>'=',
        select_search=>1},
        {field=>'ct_date'},
        {field=>'comission'},
        {field=>'result_amnt'},    
        {'field'=>"ct_amnt", "title"=>"Сумма", "no_add_edit"=>1, 'filter'=>"="},
        {'field'=>"ct_currency", "title"=>"Валюта", 'filter'=>"="
        , "type"=>"select","titles"=>\@currencies },
        {'field'=>"ct_comment", "title"=>"Назначение", "no_add_edit"=>1,},
    
        {'field'=>"ct_oid", "title"=>"Оператор" , "no_add_edit"=>1, "category"=>"operators"},
    ],
    };
    $proto->{fields}->[2]->{'titles'}=$self->{accounts2view}; #&get_permit_accounts_simple($self->{user_id});
	return 'account';
}
sub document_list_uah
{
    my $self=shift;
    my $ct_aid=$self->query->param('ct_aid');
    $ct_aid=string_mysql_clean($ct_aid);
    my ($parent_aid,$debt)=$dbh->selectrow_array(q[SELECT a_id,kand_debt FROM accounts LEFT JOIN kostial_accounts_new_docs ON kand_aid=a_id WHERE a_incom_id=?],undef,$ct_aid);
    unless($parent_aid){
            ###there is must be an error message
            return $self->error(" Это не приходная программа ");
    }
    my $percent=get_service_percent_client($ct_aid,$DOC_SERVICE);
   
      my @keys;
       my @res;
    my $min_date=$dbh->selectall_arrayref(qq[SELECT YEAR('$NEW_DOC_FROM_DATE'),
                                                    MONTH('$NEW_DOC_FROM_DATE'),
                                                    DAY('$NEW_DOC_FROM_DATE')]);



        if($min_date->[0]->[0]){


        my $docs=$dbh->selectall_hashref(qq[SELECT  
                                            dr_date as d,CONCAT(MONTH(dr_date),'.',YEAR(dr_date)) as ds,
                                            sum(dr_amnt) as s,
                                            sum((dr_amnt/100)*dr_comis ) as comis
                                            FROM documents_requests WHERE 
                                            dr_aid=$ct_aid  AND dr_date>DATE_ADD('$NEW_DOC_FROM_DATE',interval 1 day)
                                            AND dr_status!='deleted'  
                                            GROUP BY d ],'d');
       
       $docs->{$NEW_DOC_FROM_DATE}={d=>$NEW_DOC_FROM_DATE,s=>$debt, comis=>$percent*($debt/100)};
        
        
        my $money_income=$dbh->selectall_hashref(qq[SELECT  
                                        ct_date as d,
                                        CONCAT(MONTH(ct_date),'.',YEAR(ct_date)) as ds ,sum(ct_amnt) as s,ct_fid
                                        FROM cashier_transactions 
                                        WHERE ct_aid=$ct_aid 
                                        AND ct_currency='$RESIDENT_CURRENCY' 
                                        AND ct_fid>0 AND ct_amnt>0 AND ct_date>'$NEW_DOC_FROM_DATE'
                                        AND  ct_status='processed'  GROUP BY ct_date ],'d');

        my $money_pay=$dbh->selectall_hashref(qq[SELECT DATE(t_ts) as d,sum(t_amnt) as s FROM 
                                                     documents_payments,documents_requests,transactions 
                                                     WHERE dr_aid=$ct_aid AND  dr_date>'$NEW_DOC_FROM_DATE' AND
                                                     dp_drid=dr_id   AND dp_tid=t_id GROUP BY d],'d');


    
        my $money_main=$dbh->selectall_arrayref(qq[SELECT  
                                        ct_date as d,CONCAT(MONTH(ct_date),'.',YEAR(ct_date)) as ds ,
                                        ct_amnt as s,
                                        ct_comment,
                                        ct_fid,
                                        ct_ext_commission
                                        FROM cashier_transactions
                                        WHERE ct_aid=$parent_aid 
                                        AND ct_currency='$RESIDENT_CURRENCY' 
                                        AND ct_fid>0 AND ct_amnt>0
                                        AND  ct_status='processed'  AND ct_date>'$NEW_DOC_FROM_DATE' 
                                        ORDER BY ct_date ]);

         my $money_transit=$dbh->selectall_arrayref(qq[SELECT  
                                        ct_date as d,CONCAT(MONTH(ct_date),'.',YEAR(ct_date)) as ds ,
                                        ct_amnt as s,ct_ext_commission as sum_perc,
                                        ct_comment,ct_fid
                                        FROM cashier_transactions 
                                        WHERE
					                     1 AND ct_aid=$parent_aid 
                                        AND ct_currency='$RESIDENT_CURRENCY' 
                                        AND ct_fid>0 AND ct_amnt<0 AND (ct_fsid=$TRANSIT OR 1)
                                        AND  ct_status='processed' AND ct_date>'$NEW_DOC_FROM_DATE'  
                                        ORDER BY ct_date  ]);

        my $money_cash_without=$dbh->selectall_arrayref(qq[SELECT  
                                        ct_date as d,CONCAT(MONTH(ct_date),'.',YEAR(ct_date)) as ds ,
                                        ct_amnt as s,ct_ext_commission,ct_comment,ct_fid
                                        FROM cashier_transactions
                                        WHERE ct_aid=$parent_aid 
                                        AND ct_currency='$RESIDENT_CURRENCY' 
                                        AND ct_fid<0 AND ct_date>'$NEW_DOC_FROM_DATE'
                                        AND  ct_status in ('processed','returned')   ORDER BY ct_date  ]);
        

        my $money_cash=$dbh->selectall_hashref(qq[SELECT  
                                        ct_date as d,CONCAT(MONTH(ct_date),'.',YEAR(ct_date)) as ds ,
                                        sum(ct_amnt) as s,ct_fid
                                        FROM cashier_transactions 
                                        WHERE ct_aid=$ct_aid 
                                        AND ct_currency='$RESIDENT_CURRENCY' 
                                        AND ct_fid<0 AND ct_date>'$NEW_DOC_FROM_DATE'
                                        AND  ct_status in ('processed','returned')
                                        GROUP BY ct_date ],'d');

                                     
      my $money_trans_to=$dbh->selectall_hashref(qq[SELECT DATE(ts) as d,
                                                        CONCAT(MONTH(ts),'.',YEAR(ts)) as ds,
                                                        sum(t_amnt) as s
                                                        FROM transfers,accounts_reports_table
                                                        WHERE 
							ct_id=t_id
							AND
							ct_ex_comis_type='transaction' 
							AND ct_status='processed'
							AND ct_aid=t_aid2
							AND t_currency='$RESIDENT_CURRENCY' 
                                                        AND DATE(ts)>'$NEW_DOC_FROM_DATE'
                                                        AND $ct_aid=t_aid2 GROUP BY d 
                                            ],'d');
    my $money_trans_from=$dbh->selectall_hashref(qq[SELECT DATE(ts) as d,
                                                        CONCAT(MONTH(ts),'.',YEAR(ts)) as ds,
                                                        sum(t_amnt) as s
                                                        FROM transfers,accounts_reports_table 
                                                        WHERE
							t_id=ct_id 
							AND
							t_currency='$RESIDENT_CURRENCY' 
							AND ct_ex_comis_type='transaction' 
							AND ct_status='processed'                                                                            
							AND ct_aid=t_aid1   
							AND DATE(ts)>'$NEW_DOC_FROM_DATE'
                                                        AND $ct_aid=t_aid1 GROUP BY d 
                                            ],'d');

#getting the min date for generating the date
        
        my $firms_hash=$dbh->selectall_hashref(q[SELECT f_id id,f_name,CONCAT(f_name,"(#", f_id,")") name FROM firms],'id');

         my $ar=generate_set_of_dates_array($min_date->[0]->[2],$min_date->[0]->[1],$min_date->[0]->[0]);
        
        $proto->{a_uah}=format_float($proto->{a_uah});
        $proto->{a_usd}=format_float($proto->{a_usd}); 
        $proto->{a_eur}=format_float($proto->{a_eur});
 
        my $sum=0;
        my $base_doc=0;
        my $fact_money=0;
        my $debt=0;
        my $without_docs=0;
        my $doc_price=0;    
        my $per=0;
        my $prev_debt=0;
        my $price_without_doc=0;
        my $sum_concl=0;
        my $size1=@$money_main;
        my $size2=@$money_transit;
        my $size3=@$money_cash_without;

        my $cur1=0;
        my $cur2=0;
        my $cur3=0;
        my ($i,$j,$fj,$fi,$z,$fz);
        my $sum_transit=0;
	
        foreach my $date (@{ $ar }){
           ($fj,$fi)=(0,0);
             if($date eq $money_main->[$cur1]->[0]){
                $fi=1;
                for($i=$cur1;$i<$size1&&$date eq $money_main->[$i]->[0];$i++){
                 
                    $fact_money+=$money_main->[$i]->[2];

                    $sum_transit+=$money_main->[$i]->[5];

                    $debt=$base_doc-$fact_money;
                    if($debt<0){
                             $price_without_doc=($debt/100)*$percent;
                             # $sum_concl+=$price_without_doc;
                          }else{
                                 $price_without_doc=0;

                          }
               
                 my %hash=(
                        date=>format_date($money_main->[$i]->[0]),
                        in=>$money_main->[$i]->[5],
                        in_cash=>0,
                        in_all_concl=>0,
                        sum_doc=>0,
                        in_base=>format_float($money_main->[$i]->[2]),
                        orig__in_base=>$money_main->[$i]->[2],
                        in_dept=>format_float($debt),
                        doc_price=>0,
                        percent=>$per,
                        price_without_doc=>format_float($price_without_doc),
                        comment=>$money_main->[$i]->[3],
                        firm=>$firms_hash->{$money_main->[$i]->[4]}->{name}
                   );
                   push @res,\%hash;
                   
                }
                    
                $cur1=$i;
          }
          if($date eq $money_cash_without->[$cur3]->[0]){
                for($z=$cur3;$z<$size3&&$date eq $money_cash_without->[$z]->[0];$z++){
                $sum_transit+=$money_cash_without->[$z]->[3];###$money_transit->[$j]->[3] is mines sum

                my %hash=(
                        date=>format_date($money_cash_without->[$z]->[0]),
                        in=>0,
                        in_cash=>0,
                        in_all=>$debt<0 ? format_float($sum_transit):0,
                        in_all_concl=>0,
                        sum_doc=>0,
                        in_base=>format_float($money_cash_without->[$z]->[2]),
                        orig__in_base=>$money_cash_without->[$z]->[2],
                        in_dept=>format_float($debt),
                        doc_price=>0,
                        percent=>$per,
                        cash_without=>$debt<0 ? format_float(abs($money_cash_without->[$z]->[3])) :0 ,
                        price_without_doc=>0,
                        comment=>$money_cash_without->[$z]->[4],
                        firm=>$firms_hash->{$money_cash_without->[$z]->[5]}->{name}
                    );
                   push @res,\%hash;
                
                }
                $fz=1;      
                $cur3=$z;


          }        


          if($date eq $money_transit->[$cur2]->[0]){
                
                for($j=$cur2;$j<$size1&&$date eq $money_transit->[$j]->[0];$j++){
                $sum_transit+=abs($money_transit->[$j]->[3]);###$money_transit->[$j]->[3] is mines sum

                       my %hash=(
                        date=>format_date($money_transit->[$j]->[0]),
                        in=>0,
                        in_cash=>0,
                        in_all=>$debt < 0 ? format_float($sum_transit) : 0,
                        in_all_concl=>0,
                        sum_doc=>0,
                        in_base=>format_float($money_transit->[$j]->[2]),
                        orig__in_base=>$money_transit->[$j]->[2],
                        in_dept=>format_float($debt),
                        doc_price=>0,
                        percent=>$per,
                        transit_without=>$debt<0 ? format_float(abs($money_transit->[$j]->[3])):0,
                        price_without_doc=>0,
                        comment=>$money_transit->[$j]->[4],
                        firm=>$firms_hash->{$money_transit->[$j]->[5]}->{name}
                    );
                   push @res,\%hash;
                
                }
                $fj=1;      
                $cur2=$j;
                
          }
             next if(!$money_income->{$date}&&!$money_trans_from->{$date}&&!$money_trans_to->{$date}&&!$money_pay->{$date}&&!$money_cash->{$date}&&!$docs->{$date}&&!$fi&&!$fj);

            my $in=$money_income->{$date}->{'s'};
            $in-=$money_trans_from->{$date}->{'s'};
            $in+=$money_trans_to->{$date}->{'s'};
            $in+=$money_pay->{$date}->{'s'};
          
            
            $sum+=$in;
            my $cash=$money_cash->{$date}->{'s'};

            $sum+=$cash;
            
            $base_doc+=$docs->{$date}->{'s'};

#             $fact_money+=$money_main->{$date}->{'s'};

            $debt=$base_doc-$fact_money;

            $doc_price+=$docs->{$date}->{'comis'};

            $sum_concl=$sum-$doc_price;
            
 
             if($debt<0){

                 $price_without_doc=($debt/100)*$percent;
#                $sum_concl+=$price_without_doc;
            
             }else{
                
                $price_without_doc=0;
                $sum_transit=0;
             }

            
            if($docs->{$date}->{'s'}){
                      $per=format_float($docs->{$date}->{'comis'}/($docs->{$date}->{'s'}/100));
            }else{
                $per=0;
            }
           # $sum-=($without_docs/100)*$percent;
                #in_base_without_doc=>format_float($without_docs),
            my %hash=(
                concl=>1,
                date=>format_date($date),
                in=>format_float($in),
                in_cash=>format_float($cash),
                all=>format_float($sum_transit+$sum_concl),
                in_all_concl=>format_float($sum_concl),
                in_all=>format_float($sum_transit),
                sum_doc=>format_float($docs->{$date}->{'s'}),
                in_base=>0,
                in_dept=>format_float($debt),
                doc_price=>format_float(-$docs->{$date}->{'comis'}),
                percent=>$per,
                price_without_doc=>format_float($price_without_doc),
            );
            push @res,\%hash;






    }
    
    @res=reverse @res;
    $prev_debt=$debt;
    
    $self->{tpl_vars}->{fields}=$proto->{fields};
    $self->{tpl_vars}->{proto_params}=$proto;
    $self->{tpl_vars}->{rows}=\@res;
    }
   my $output = "";
   my $tmpl=$self->load_tmpl('accounts_docs_list.html');


   $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   return $output;

           #in this cat all cards begin from zero

        



#        <td style="width:6em" class=table_gborders>Дата $row.date</td>
#         <td class=table_gborders>$row.in </td><!--Б/н приход-->
#         <td class="table_gborders">$row.in_day_concl<!--Итого (ГРН) за день--></td> 
#         <td class="table_gborders">$row.in_all_concl<!--Всего--> </td>
#         <td class=table_gborders>$row.in_cash<!--Касса--></td>      
#         <td class=table_gborders>$row.sum_doc<!--База приходы--></td>
#         <td class=table_gborders> $row.percent<!--%доки--> </td>
#         <td class=table_gborders>$row.doc_price<!--Стоимость док--></td>
#         <td class=table_gborders>$row.in_base<!--б/н приходы--></td><!--базовая программа-->
#         <td class=table_gborders>$row.in_dept<!--Долг док.--></td>
#         <td class=table_gborders>$row.in_base_without_doc<!--Безнал без док--></td>
#         <td class=table_gborders>$row.price_without_doc<!--стоимость без док--></td>
#         <td style="width:12em" class=table_gborders>Просмотреть<!--Примечания--> </td>
#         <td style="width:12em" class=table_gborders>Просмотреть<!--От кого--> </td>
        
    


 



}


sub list
{
	my $self = shift;
	my $del_to=$self->query->param('del_to');
	if ($del_to)
	{
	   	$proto->{'extra_where'}='';
		$proto->{del_to}=1;
	}else
	{
		 $proto->{'extra_where'}=q[ ct_status!='deleted' ];
		$proto->{del_to}=0;
	}

	my $start_amnts;
	my $fid=$self->query->param('ct_aid');

         my $docs;
 	if($fid)	
 	{

 		my $type=$self->query->param('type_time_filter');

 		my $ref=$dbh->selectrow_hashref(q[SELECT * FROM accounts WHERE a_id=?],undef,$fid);	
	    
        if($ref->{a_acid}==$INCOME_CATEGORY){

             $proto->{dates_comment}=$dbh->selectall_hashref(qq[SELECT 
                                                                aric_date,
                                                                aric_comment as comment
                                                                FROM
                                                                accounts_reports_in_comment 
                                                                WHERE
                                                                aric_aid=$ref->{a_id}
                                                                ],'aric_date',);

       }
        

        my $income=$dbh->selectrow_hashref(q[SELECT * FROM accounts WHERE a_id=?],undef,$ref->{a_incom_id}); 



	    $docs=document_list_uah_concl($ref->{a_incom_id});
    
 		my $row=$dbh->selectrow_array(q[SELECT ah_ts FROM accounts_history 
		WHERE ah_aid=? AND ah_status!='deleted' ORDER BY ah_id DESC LIMIT 1],undef,$fid);	


		map { $proto->{$_}=$ref->{$_} } keys %$ref;
		
		#$proto->{a_usd_eq}=format_float($ref->{a_usd_eq});
        
        $proto->{a_incom_id}=$ref->{a_incom_id};
        $proto->{a_incom_uah}=format_float($income->{a_uah});

        $proto->{a_uah}=format_float($proto->{a_uah});
        $proto->{a_usd}=format_float($proto->{a_usd}); 
        $proto->{a_eur}=format_float($proto->{a_eur}); 
        $proto->{a_btc}=format_float($proto->{a_btc});
        $proto->{a_gbp}=format_float($proto->{a_gbp});
        $proto->{a_rub}=format_float($proto->{a_rub});
        
		
        $proto->{a_name}=$ref->{a_name};


##this code do nothing
		my @filter_where;
		push @filter_where,$row if($proto->{table} eq 'accounts_reports_table');
		$filter_where[0]='0000-00-00 00:00:00' unless($filter_where[0]);
	##this code do nothing 	

		my $sums=calculate_sum_with(
				{
					a_id=>$fid,
					date_from=>$filter_where[0],
					date_to=>$filter_where[1],
					date2=>" 1 ",
					date1=>' 1 ',   
					table=>$proto->{table}
				}
				);

 		$proto->{beg_uah}=$ref->{a_uah}-$sums->{UAH};		
  		$proto->{beg_usd}=$ref->{a_usd}-$sums->{USD};
  		$proto->{beg_eur}=$ref->{a_eur}-$sums->{EUR};
  		$proto->{beg_btc}=$ref->{a_btc}-$sums->{BTC};
  		$proto->{beg_gbp}=$ref->{a_btc}-$sums->{GBP};
  		$proto->{beg_rub}=$ref->{a_btc}-$sums->{RUB};


		
		$proto->{orig__beg_uah}=$proto->{beg_uah};
  		$proto->{orig__beg_usd}=$proto->{beg_usd};
  		$proto->{orig__beg_eur}=$proto->{beg_eur};
  		$proto->{orig__beg_btc}=$proto->{beg_btc};
  		$proto->{orig__beg_gbp}=$proto->{beg_gbp};
  		$proto->{orig__beg_rub}=$proto->{beg_rub};
	
		$proto->{beg_uah}=format_float($proto->{beg_uah});
  		$proto->{beg_usd}=format_float($proto->{beg_usd});
  		$proto->{beg_eur}=format_float($proto->{beg_eur});
  		$proto->{beg_btc}=format_float($proto->{beg_btc});
  		$proto->{beg_rub}=format_float($proto->{beg_rub});
  		$proto->{beg_gbp}=format_float($proto->{beg_gbp});

  		
		$proto->{from_date}=format_date($filter_where[0]);
 		$proto->{to_date}=format_date($filter_where[1]);
 		$proto->{reports_rate}=$dbh->selectall_hashref(qq[SELECT 
						rr_rate,rr_date
						FROM reports_rate 
		 				WHERE 
						rr_date>='$filter_where[0]' AND 
						rr_date<='$filter_where[1]'],'rr_date');
 		
 	}	

	$proto->{checked_all}=$dbh->selectrow_array(q[SELECT count(*) FROM accounts_reports_table WHERE ct_status!='deleted' AND ct_aid=?],undef,$fid)==$dbh->selectrow_array(q[SELECT count(*) FROM accounts_reports_table WHERE ct_status!='deleted' AND col_status='yes' AND ct_aid=?],undef,$fid);

	 $proto->{'info'}=get_client_oper_info($fid);


    	 $proto->{'ct_aid'}=$fid;
     	 $proto->{'sort'}=' ts ASC';
   	 my %hash;
       	

	$proto->{sums}=\%hash;		
    $proto->{docs}=$docs;

	return $self->proto_list($proto,{fetch_row=>\&sum,after_list=>\&last_record});


}
1;
	

