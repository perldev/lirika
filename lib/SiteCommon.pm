package SiteCommon;

use strict;

use SiteDB;	
use SiteConfig;
use base "Exporter";
use POSIX;
# use MyFormat;

our @EXPORT = qw(
        $avail_currency @months
	    get_system_last_rates
        &get_card_percent_serivce
        paging
        trim
        add2list
        set2hash
        get_rates
        to_prec4
        get_exchanges
        $session_upgrade
        &get_accounts
        &get_translit
        lowpow
        now
            get_desc_rights_array
            &get_client_classes
            &get_classes
            &get_cash_trans_sum
            &get_firm_name
            &get_info_of_trans
            &handle_errors_add_trans
            &get_firm_information
            &get_account_name
            &get_cache_connection
            &get_accounts_simple
            &get_accounts_simple_with_block
            &get_service_name
            &send_mail
            normal_prec
        &calculate_sum
            &calculate_sum_without
            &sum_credit
            &last_record_credit
            &to_prec
            &get_desc_rights
            &set_desc_rights
            &get_operators
            &get_services_percents_client
            &get_services
            &get_services_percents
            &get_client_services_percents
            &format_float_inner
            &get_firms
        &get_cash_services
        @time_filter_rows
        &time_filter
        $chat_last_mesgs
        @currencies
            &get_whole_exchanges
            &get_transit_list
            &get_trans_list
            &get_firm
        &get_firm_services_percents
            &format_date
            &format_datetime
            &format_float
            &pow
        &generate_set_of_dates_array
            &to_prec6    
            $predkassa_id
            $default_kassa_id
            $svoj_id
            $firms_id
            $exchange_id
            $credit_id
            $conv_currency
            $now_hash
            $FIRMS_TRANSACTIONS
            $avail_currency_firms
            &format_string_inner_sql
            get_client_oper_info
            &calculate_sum_with
            $VAL_PAYMENTS
            andrey_float_format  
            $FIRMS_CONV
            @currencies_withbtc
            %MAIN_STATUSES
            $RESIDENT_CURRENCY
            $DOCUMENTS
            $SQL_DELAYED
            $FIFO
            $FIFO_O
            $FIFO_F
            $LOCAL_FLAG
    get_static_plugins
            &get_special_services
            $DELTA
            $DELTA_W
            &error_process
            &last_record
            &sum
            $CORRECT
            &sum_
            &get_cash_conclusions
            &get_exchanges_cash
            &get_cats	
            &get_cats_simple
            &my_decode
            &get_real_aid
        %months
        format_datetime_month_year 
        get_transaction_info
        check_number
        check_currency
        check_user
        check_text
        check_ts
        $ETALON_VALUE_COMIS
        string_mysql_clean
        last_record_doc
        sum_doc
        get_service_percent_client
        $DOC_SERVICE
        $TRANSIT
        $STAND_MIS
        $NEW_DOC_FROM_DATE
        document_list_uah_concl
        $kassa_id
        $SPECIAL_ACCOUNTS
        $SYSTEM_ACCOUNTS
        &get_avail_cash_offices
        $DEF_COLOR
        $MAIN_CLIENT_CATEGORY
        %months_days
        &get_avail_cash_offices_hash
        $FILTER_NUMBER_MISTAKE
        get_doc_pecent
        $MUST_ARCHIVE_NUMER
        $INCOME_CATEGORY
        my_log
        $SERVER_DATA_PATH
        $DEFAULT_DOCUMENT_PERCENT
        get_out_firms_hash
        myformat_float
        $STATIC_CLASS
        $NEEDED_CAT
        $MAIL_SERVICE
        get_permit_accounts_simple
);
our $SERVER_DATA_PATH='/usr/local/www/';
our $session_upgrade=5;
our %MAIN_STATUSES=('created'=>'Создана',transit=>'Транзит','canceled'=>'Отменена','processed'=>'Проведена');	
our $INCOME_CATEGORY=16;
our $NEW_DOC_FROM_DATE='2009-09-30';
# special aid & fid
our $LOCAL_FLAG=0;
our $kassa_id = -2;
our $MUST_ARCHIVE_NUMER=2000;## if the number of the records in the card more than this value underline it
our $default_kassa_id=-1;
our $DELTA = -7;
our $DELTA_W=-8;
our $FILTER_NUMBER_MISTAKE=0.0003;
our $ETALON_VALUE_COMIS=10;
our $DOCUMENTS=1386;
our $DOC_SERVICE=55;
our $DEF_COLOR=16777215;
our $TRANSIT=47;
our $STATIC_CLASS=22;
our $NEEDED_CAT=3;
our $VAL_PAYMENTS=544;
our $svoj_id      = -3;
our $firms_id     = -4;
our $exchange_id  = -5;
our $credit_id    = -6;
our $CORRECT = 544;
our $FIFO='/tmp/.in_flag';
our $FIFO_O='/tmp/.out_flag';
our $FIFO_F='/tmp/.f_flag';
our $STAND_MIS=0.001;
our $SPECIAL_ACCOUNTS=-2;
our $SYSTEM_ACCOUNTS=-1;
our $MAIN_CLIENT_CATEGORY=2;
our $MAIL_SERVICE='89.28.202.146';
our $FIRMS_TRANSACTIONS=-13;
our $RESIDENT_CURRENCY='UAH';
our $FIRMS_CONV=-2;
our $now_hash = now();


our $avail_currency={UAH=>'a_uah',USD=>'a_usd',EUR=>'a_eur', BTC=>'a_btc', GBP=>'a_gbp', RUB=>'a_rub',};
our $avail_currency_firms={UAH=>'f_uah',USD=>'f_usd',EUR=>'f_eur', BTC=>'f_btc', GBP=>'f_gbp', RUB=>'f_rub',};
our $conv_currency={UAH=>'ГРН',USD=>'USD',EUR=>'EUR',BTC=>'BTC',GBP=>'GBP',RUB=>'RUB', };

our $chat_last_mesgs=' 2 hour ';
our $DEFAULT_DOCUMENT_PERCENT=2.5;
our $SQL_DELAYED='  ';

our @months=
        (
                {value=>1,name=>'Январь'},
                {value=>2,name=>'Февраль'},
                {value=>3,name=>'Март'},
                {value=>4,name=>'Апрель'},
                {value=>5,name=>'Май'}, 
                {value=>6,name=>'Июнь'},
                {value=>7,name=>'Июль'},
                {value=>8,name=>'Август'},
                {value=>9,name=>'Сентябрь'},
                {value=>10,name=>'Октябрь'},
                {value=>11,name=>'Ноябрь'},
                {value=>12,name=>'Декабрь'}
        );      
our %months=
        (
                '01'=>'Январь',
                '02'=>'Февраль',
                '03'=>'Март',
                '04'=>'Апрель',
                '05'=>'Май', 
                '06'=>'Июнь',
                '07'=>'Июль',
                '08'=>'Август',
                '09'=>'Сентябрь',
                10=>'Октябрь',
                11=>'Ноябрь',
                12=>'Декабрь',
                1=>'Январь',
                2=>'Февраль',
                3=>'Март',
                4=>'Апрель',
                5=>'Май', 
                6=>'Июнь',
                7=>'Июль',
                8=>'Август',
                9=>'Сентябрь',
        );      
our %months_days=
        (
                1=>31,
                2=>28,
                3=>31,
                4=>30,
                5=>31, 
                6=>30,
                7=>31,
                8=>31,
                9=>30,
                10=>31,
                11=>30,
                12=>31,

                );      



our @time_filter_rows=(
 {value=>"today",      title=>"Сегодня"},
 {value=>"yesterday",  title=>"Вчера"},
 {value=>"this_week",  title=>"Эта неделя"},
 {value=>"prev_week",  title=>"Пред. неделя"},
 {value=>"last_20",  title=>"Посл 20 дней"},
 {value=>"this_month", title=>"Этот месяц"},
 {value=>"prev_month", title=>"Предыдущий месяц"},
 {value=>"prev_2month", title=>"Посл. 2 месяца"},
 {value=>"prev_3month", title=>"Посл. квартал"},
 {value=>"this_year",  title=>"Этот год"},
 {value=>"prev_year",  title=>"Пред.год"},
 
);
#{value=>"all_time",   title=>"Весь период"},
our @currencies=(
 	{'value'=>"", 'title'=>"Выбрать валюту"},
        {'value'=>"UAH", 'title'=>"ГРН"},
        {'value'=>"USD", 'title'=>"USD"},
        {'value'=>"GBP", 'title'=>"GBP"},
        {'value'=>"RUB", 'title'=>"RUB"},
        {'value'=>"EUR", 'title'=>"EUR"},
);

our @currencies_withbtc= (
        {'value'=>"", 'title'=>"Выбрать валюту"},
        {'value'=>"UAH", 'title'=>"ГРН"},
        {'value'=>"USD", 'title'=>"USD"},
        {'value'=>"EUR", 'title'=>"EUR"},
        {'value'=>"GBP", 'title'=>"GBP"},
        {'value'=>"RUB", 'title'=>"RUB"},
        {'value'=>"BTC", 'title'=>"BTC"},



);
#for calculating accounts_reports
##and using in the reports
my %replace_lit=(
	'q'=>'й',
	'w'=>'ц',
	'e'=>'у',
	'r'=>'к',
	't'=>'е',
	'y'=>'н',
	'u'=>'г',
	'i'=>'ш',
	'o'=>'щ',
	'p'=>'з',
	'['=>'х',
	']'=>'ъ',
	'a'=>'ф',
	's'=>'ы',
	'd'=>'в',
	'f'=>'а',
	'g'=>'п',
	'h'=>'р',
	'j'=>'о',
	'k'=>'л',
	'l'=>'д',
	';'=>'ж',
	'\''=>'э',
	'\\'=>'\\',
	'z'=>'я',
	'x'=>'ч',
	'c'=>'с',
	'v'=>'м',
	'b'=>'и',
	'n'=>'т',
	'm'=>'ь',
	','=>'б',
	'.'=>'ю',
	'/'=>'/',
);

sub myformat_float
{
    my $dig = shift;
    return format_float($dig);
=pod
    my @tmp = split(/\./,$dig);
    #die("'@tmp' - $dig");
    my $ret = $tmp[0];
    $ret =~ s/(?<=\d)(?=(\d{3})+(?!\d))/ /g;
    return $ret unless($tmp[1]);
    return "$ret.$tmp[1]";
=cut

}
sub my_log{
    my $self=shift;
    my $time=shift;
    my $param=$self->query->param('do');
    $param='list' unless($param);
    my $msg=$ENV{SCRIPT_NAME}."?do=$param";
    $dbh->do(q[INSERT INTO logs_posts(log_time,log_post,lp_oid) VALUES(?,?,?)],undef,$time,$msg,$self->{user_id});
}
sub get_out_firms_hash{
    
    return $dbh->selectall_hashref(q[SELECT of_name as title,of_id FROM out_firms  ],'of_id');

}
sub get_doc_pecent{

    my ($aid,$date)=@_;
    my $percent=$dbh->selectrow_array(qq[SELECT cs_percent FROM accounts,
                    client_services
                    WHERE a_id=? AND cs_aid=a_id AND  cs_month=MONTH('$date') AND 
                    cs_year=YEAR('$date') AND  cs_fsid=? ],undef,$aid,$DOC_SERVICE);
     if($percent){
        return $percent;

    }


    $percent=$dbh->selectrow_array(qq[SELECT cs_percent FROM accounts,
                    client_services
                    WHERE a_id=? AND cs_aid=a_id AND  cs_month<=MONTH('$date') AND 
                    cs_year<=YEAR('$date') AND  cs_fsid=? ORDER BY cs_ts  LIMIT 1],undef,$aid,$DOC_SERVICE);
 
    return $DEFAULT_DOCUMENT_PERCENT unless($percent);###for very old records
    return $percent;
}


sub get_avail_cash_offices_hash{
    my $self=shift;
    my $ref=$dbh->selectall_hashref(q[SELECT co_name,co_aid as id,co_title  as name FROM cash_offices WHERE 1],'co_name');
    my $rights=$self->{rights}; 
    
    my %avail;
    
    my @avail;
    
    
    foreach my $t (%$rights){
    
         if($t=~/cash/){
            $t=~/_([^_]+)$/;
        my $tt=$1;
        $avail{$tt}=$ref->{$tt};  
        $avail{ $ref->{$tt}->{id} }=$ref->{$tt};         
   
        }
    }
    return \%avail;
    
    


}
sub get_avail_cash_offices{
    my $self=shift;
    my $ref=$dbh->selectall_hashref(q[SELECT co_name,co_aid as id,co_title  as name FROM cash_offices WHERE 1],'co_name');
    my $rights=$self->{rights}; 
    
    my %avail;
    
    my @avail;
    
    
    foreach my $t (%$rights){
    
         if($t=~/cash/){
	        $t=~/_([^_]+)$/;
		my $tt=$1;
		push  @avail,$ref->{$tt} unless($avail{$tt});                  
                $avail{$tt}=1;     
        }
    }
    return \@avail;
    
    


}

sub string_mysql_clean{
    my $str=shift;
    $str=~s/["'\\  ]//g;
    return $str;


}

sub check_currency
{
    my $cur=shift;
    return  1 unless($avail_currency->{$cur});
    return 0;

}
sub check_user
{
    my $user=shift;
    return 1 unless($dbh->selectrow_array(q[SELECT a_id FROM accounts WHERE a_id=?],undef,$user));
    return 0;


}
sub check_number
{
    my $number=shift;
    $number=~s/[,]/\./g;##for blonds
    $number=~s/[ ]//g;
    return  1 if(!$number&&!$number =~ /^\s*[+-]?\d+\.?\d*\s*$/);
    return 0;


}
sub check_ts
{
    my $number=shift;
    return  1 if($number !~ /\d\d\d\d-\d\d-\d\d/);
    return 0;

}
sub check_text
{
    my $text=shift;
    return 1    unless($text);
    return 0;

}
sub get_transaction_info
{

    return $dbh->selectrow_hashref(q[SELECT * FROM transactions WHERE t_id=?],undef,shift);

}
sub get_system_last_rates{
    
    return    $dbh->selectrow_hashref(q[SELECT sr_uah_domi as UAH,sr_eur_domi as EUR 
				    FROM system_rates ORDER BY sr_id DESC LIMIT 1]);

}

sub get_real_aid
{
	my $id=shift;
	return $id;
	my $parent=$dbh->selectrow_array(q[SELECT ah_aid_parent_id 
	FROM accounts_history WHERE ah_aid=?],undef,$id);	
	if($parent)
	{
		return $dbh->selectrow_array(q[SELECT 
		ah_new_aid FROM accounts_history WHERE ah_aid_parent_id=? AND ah_id=(SELECT
		max(ah_id) FROM accounts_history WHERE ah_aid_parent_id=? )],undef,$parent,$parent);	

	}
	else
	{
		return  $id;
	
	}



}
sub get_translit
{
	my $str=shift;
	my @ar=split(//,lc $str);
	my $size=@ar;
	for(my $i=0;$i<$size;$i++)
	{
		if($replace_lit{$ar[$i]})
		{
			$ar[$i]=$replace_lit{$ar[$i]};
		}
	}
	return join('',@ar);


}
sub get_cats_simple
{

	my $id=shift;
    my $exclude=shift;
    my $ex_str='';
    if($exclude){
            
       $ex_str=join(',',@$exclude);
       $ex_str="ac_id NOT IN ($ex_str)"; 

    }else{
        $ex_str='1'
    }
    my @res;
	my $sth=$dbh->prepare(qq[SELECT ac_id,ac_title,ac_acid FROM accounts_cats WHERE $ex_str ORDER BY ac_id]);
	$sth->execute();
	
	while(my $r=$sth->fetchrow_hashref())
	{
		
		$r->{selected}=($id==$r->{ac_id});

		$r->{title}=$r->{ac_title};

		$r->{value}=$r->{ac_id};
		
		push @res,$r;

	}
	$sth->finish();
	my @res1=();
	cat_sort(\@res,\@res1,{parent_name=>'ac_acid',id_name=>'ac_id'},0,0);
	

	return \@res1;

}

sub get_cats
{
	my $id=shift;
	my $ref=get_cats_simple($id);
	add_delimiter($ref," -  - ");	
	return $ref;

	

}
sub add_delimiter
{
	my ($res,$del)=@_;
	my $i=0;
	my $str='';
	foreach(@$res)
	{
		$str=$_->{title};
		for($i=1;$i<$_->{level};$i++)
		{
			$str=$del.$str;
		}
		$_->{title}=$str;
				
	}


}
sub cat_sort
{
	my ($ref,$ar,$params,$parent_id,$level)=@_;
	my $size=@$ref;
	

	for(my $i=0;$i<$size;$i++)
	{
		if($ref->[$i]->{$params->{parent_name}}==$parent_id)
		{		
			$level+=1;
			$ref->[$i]->{level}=$level;
			push @{$ar},$ref->[$i];
			foreach(@$ref)			
			{
				 if($_->{$params->{parent_name}}==$ref->[$i]->{$params->{id_name}})
				 {
					$level+=1;
					$_->{level}=$level;
					push @{$ar},$_;
					cat_sort($ref,$ar,$params,$_->{$params->{id_name}},$level);
					$level-=1;
				 }
				
			}
			$level-=1;
		}


	}
	$level-=1;
}

sub my_decode
{
	my $r=shift;
	require Encode;
	Encode::from_to($r,'cp1251','utf8');
	utf8::decode($r);
	return $r;

}
sub format_string_inner_sql
{
	my $r=shift;
	$r=trim($r);
	$r=~s/['\\]/\\$1/g;
	
	return "'$r'";

}


sub to_prec
{
	my $amnt=shift;
	if(ref($amnt))
	{
		$$amnt=ceil($$amnt*100)/100;
		return $$amnt;	
	}else
	{
		return ceil($amnt*100)/100;
	}	
	
}
sub to_prec6
{
        	my $amnt=shift;
	        if(ref($amnt))
		 {
			$$amnt=ceil($$amnt*1000000)/1000000;
			return $$amnt;
		}else
		{
			return ceil($amnt*1000000)/1000000;
		} 
}
sub to_prec4
{
        	my $amnt=shift;
	        if(ref($amnt))
		 {
			$$amnt=ceil($$amnt*10000)/10000;
			return $$amnt;
		}else
		{
			return ceil($amnt*10000)/10000;
		} 
}


sub get_client_oper_info
{

   my $fid=shift;
   my $cash=$dbh->selectall_hashref(q[SELECT co_aid FROM  cash_offices ],'co_aid');
   my $cash_str=join(',',keys %$cash);


    my $operations_info=$dbh->prepare(qq[
    SELECT sum(ct_amnt) as cash_in_uah,0 FROM cashier_transactions WHERE ct_status='processed' 
        AND ct_fid in ($cash_str) AND ct_amnt>0 AND ct_aid=? AND ct_currency='UAH' UNION ALL 
    SELECT sum(ct_amnt) as cash_out_uah,0 FROM cashier_transactions WHERE ct_status='processed' 
        AND ct_fid in ($cash_str) AND ct_amnt<0  AND ct_aid=?  AND ct_currency='UAH' 
    UNION ALL
    SELECT sum(ct_amnt) as bn_in_uah,
    sum(if(
    `cashier_transactions`.`ct_eid` is not NULL AND `cashier_transactions`.`ct_tid2_comis` is NULL,
    ((1 / `exchange_view`.`e_rate`) * 
    ((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_amnt`) - 
    (`cashier_transactions`.`ct_amnt` * 
    (`exchange_view`.`e_rate` + 
    ((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
    ((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100)
    )) as bn_in_uah_com  
    FROM cashier_transactions   LEFT JOIN exchange_view ON ct_eid=e_id WHERE ct_status='processed'
        AND ct_fid>0 AND ct_amnt>0 AND ct_aid=? AND ct_currency='UAH'  GROUP BY ct_aid
    UNION ALL 
    SELECT sum(ct_amnt) as bn_out_uah,sum(if(
    `cashier_transactions`.`ct_eid` is not NULL AND `cashier_transactions`.`ct_tid2_comis` is NULL,
    ((1 / `exchange_view`.`e_rate`) * 
    ((`exchange_view`.`e_rate` * abs(`cashier_transactions`.`ct_amnt`)) - 
    (abs(`cashier_transactions`.`ct_amnt`) * 
    (`exchange_view`.`e_rate` + 
    ((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
    ((abs(`cashier_transactions`.`ct_amnt`) * `cashier_transactions`.`ct_comis_percent`) / 100)
    )) as bn_out_uah_com  FROM cashier_transactions 
     LEFT JOIN exchange_view ON ct_eid=e_id WHERE ct_status='processed' 
        AND  ct_fid>0 AND ct_amnt<0  AND ct_aid=?  AND ct_currency='UAH'  
    GROUP BY ct_aid
    ]);

    $operations_info->execute($fid,$fid,$fid,$fid);
    my $id={
        1=>'cash_in_uah',
        2=>'cash_out_uah',
        3=>'cash_in_usd',
        4=>'cash_out_usd',
        5=>'cash_in_eur',
        6=>'cash_out_eur',
        7=>'bn_in_uah',
        8=>'bn_out_uah',
        9=>'bn_in_usd',
        10=>'bn_out_usd',
        11=>'bn_in_eur',
        12=>'bn_out_eur',
    };

    my $i=1;
    my $info={};
    while(my $r=$operations_info->fetchrow_arrayref())
    {
        
        $info->{$id->{$i}}=format_float(abs($r->[0]));
        $info->{$id->{$i}.'_com'}=format_float((abs($r->[1])));
        $i++;   
    }
    $operations_info->finish();
    return $info;

}   

sub error_process
{
	my ($self,$msg,$ref)=@_;
	if(!$ref||!$ref->{'sub'})
	{
		return default_error($self,$msg);

	}else
	{
		return $ref->{'sub'}->($self,$msg,$ref);	

	}

}
sub calculate_sum_without
{
    my $ref=shift;
    
       $ref->{compare}=$dbh->selectrow_array(qq[SELECT TIME_TO_SEC('$ref->{date_from}')+TO_DAYS('$ref->{date_from}')*864000 ]);    

####blyad!!!
    my $sth =$dbh->prepare(qq[
                SELECT
                SQL_CALC_FOUND_ROWS * FROM accounts_reports_table
                WHERE ct_aid=?
	        AND ct_fid NOT IN (30,33,34,35,744,745,668,669,670,767,766,768)
                AND $ref->{date1}
                AND $ref->{date2} ORDER BY ts ASC
              ]);    
	      
#              $ref->{compare}=$dbh->selectrow_array(qq[SELECT TIME_TO_SEC('$ref->{date_from}')+TO_DAYS('$ref->{date_from}')*864000 ]);                             
               $sth->execute($ref->{a_id});        
#              $ref->{compare}=$dbh->selectrow_array(qq[SELECT TIME_TO_SEC('$ref->{date_from}')+TO_DAYS('$ref->{date_from}')*864000 ]);                                                                                                                         
               my $proto={};                                                                                                                                       
               my %hash;                                                                                                                                          
               $proto->{sums}=\%hash;                                                                                                                              
            #post formating                                                                                                                                     
               my $prev_row=undef;##for first row the prev row will be undef                                                                                       
               my $r;                                                                                                                                              
               my @rows;                                                                                                                                           
    while( $r = $sth->fetchrow_hashref)                                                                                                                 
     {                                                                                                                                                   
                     #copied from CGIBASE but in light version                                                                                            
                 ##if  we defind a sub of working with te record                                                                                      
                     sum_(\@rows,$r,$prev_row,$proto,$ref->{compare});                                                                                    
                     $prev_row=$r->{ct_date};                                                                                                             
    }                                                                                                                                                   

          $sth->finish();                                                                                                                                      
  return $proto->{sums}->{$prev_row};          
}

sub send_mail
{
	   
       my $body=shift;
	   my $max=$dbh->selectrow_array(q[SELECT count(*) FROM emails ]);
	   my $ref=$dbh->selectrow_hashref(
	    q[SELECT em_id,em_user,em_pwd,em_port,em_smtp,em_mail
	     			FROM emails WHERE em_id=?],undef,int(rand($max))||1);

	   require EasyMail;
	#    $ref->{em_smtp}='smtp.nm.ru';
	#    $ref->{em_user}='mysterio@nm.ru';
	#    $ref->{em_pwd}='dasha';

	    $body->{file_name}='report.rar'    unless($body->{file_name});

	   my $files=[ {file_path=>$body->{file},file_name=>$body->{file_name} } ];
	   my $mail = {
                              'sender_type' =>'SENDMAIL', # 'SMTPAUTHLOGIN',
#                              'smtp_host' => '127.0.0.1',
#                              'smtp_port' =>$ref->{em_port} ,
#                              'smtp_usr' => $ref->{em_user},
#                              'smtp_pass' =>$ref->{em_pwd},
                              'type' => 'html',
                              'subject' => "screpka! $body->{a_name}",
			                  'files'=>$files ,
                              'body' => 'This letter has been generated by robot!Do not answer on it!',
                              'from' =>'zlobniiadmin@ftrans.dp.ua',
                              'to' =>$body->{mail_to} ,
                              'return_path' => '/tmp/failmail',
                              'src_encoding' => 'utf8',
                              'dst' => 'un',
			      'sendmail_path' => '/usr/sbin/sendmail', 
			      
            };
	    
		
            EasyMail::sendmail($mail) or die " Проверьте настройки почты для $ref->{em_email}";
	
}
sub default_error
{
	my ($self,$msg)=@_;
	my $vars = {};
	my $tmpl=$self->load_tmpl('proto_error.html');
	$self->{tpl_vars}->{error}=$msg;
       my $output = "";
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;

}

sub last_record_credit
{
	my ($rows,$row,$prew,$proto)=@_;

	$proto->{reports_rate}->{$prew} ={rr_rate=>5.05} unless( $proto->{reports_rate}->{ $prew }); 
	$proto->{beg_uah}=$proto->{beg_uah};
  	$proto->{beg_usd}=$proto->{beg_usd};
  	$proto->{beg_eur}=$proto->{beg_eur};
	$proto->{is_credit}=1;
	
	##it's need in order to make a wright functionality in working with archives

	
	

	unless( defined($prew) )   
	{
###if there'nt any operations		
	
		$proto->{a_uah}=format_float($proto->{orig__beg_uah});
   		$proto->{a_usd}=format_float($proto->{orig__beg_usd});
 		$proto->{a_eur}=format_float($proto->{orig__beg_eur});
		
		
		##includin today

	my $concl_sum=$proto->{"orig__beg_".lc($proto->{credit_currency})};


	

	


	if($concl_sum<0){
		my $days=abs(get_date_diff($proto->{beg_calc_date},$proto->{fin_calc_date}))+1;##includin ended day

		my $tm_sum=$days*($proto->{credit}->{day_percent}*$concl_sum);

		$tm_sum=ceil($tm_sum*100)/100;
		$proto->{credit}->{sum}+=$tm_sum;
		push @$rows,{ct_ex_comis_type=>'transaction',ct_date=>format_date($proto->{beg_calc_date}),
				ct_currency=>$proto->{credit_currency},
                orig__ct_currency=>$proto->{credit_currency},ct_fid=>$credit_id,f_name=>'Credit',
				orig__ct_amnt=>$tm_sum,
				ct_amnt=>format_float($tm_sum),
				result_amnt=>$tm_sum,
				ct_comment=>qq[Начисление кредита за $days дня $proto->{credit_currency}],
				col_status=>'no'};

	}

		pop @{$proto->{fields}};
		
		$proto->{fin_uah}=format_float($proto->{orig__beg_uah});
  		$proto->{fin_usd}=format_float($proto->{orig__beg_usd});
  		$proto->{fin_eur}=format_float($proto->{orig__beg_eur});		
	


		push @$rows,{
			ct_ex_comis_type=>'concl',ct_date=>format_date($proto->{beg_calc_date}),
 			      	UAH=>$proto->{orig__beg_uah},
 			      	USD=>$proto->{orig__beg_usd},
				EUR=>$proto->{orig__beg_eur},
			UAH_FORMAT=>format_float($proto->{orig__beg_uah}),
			USD_FORMAT=>format_float($proto->{orig__beg_usd}),
			EUR_FORMAT=>format_float($proto->{orig__beg_eur}),
			
 			     };


	}else{

		
		my $concl_sum=$proto->{sums}->{ $prew }->{$proto->{credit_currency}};

		if($concl_sum<0)
		{
				
				my $days=abs(get_date_diff($prew,$proto->{fin_calc_date}))+1;##includin today

				my $tm_sum=$days*($proto->{credit}->{day_percent}*$concl_sum);

				$tm_sum=ceil($tm_sum*100)/100;

				$proto->{credit}->{sum}+=$tm_sum;

			push @$rows,{ct_ex_comis_type=>'transaction',ct_date=>format_date($prew),
				ct_currency=>$proto->{credit_currency},
                orig__ct_currency=>$proto->{credit_currency},ct_fid=>$credit_id,f_name=>'Credit',
				orig__ct_amnt=>$tm_sum,
				ct_amnt=>format_float($tm_sum),
				result_amnt=>$tm_sum,
				ct_comment=>qq[Начисление кредита за $days дня в $proto->{credit_currency} ],
				col_status=>'no'};
		
		}	
		
		
 		push @$rows,{ct_ex_comis_type=>'concl',ct_date=>"Итого :",
  			      	UAH=>	$proto->{sums}->{ $prew }->{'UAH'},
  			      	USD=>	$proto->{sums}->{ $prew }->{'USD'},
 				EUR=>	$proto->{sums}->{ $prew }->{'EUR'},
 				UAH_FORMAT=>format_float($proto->{sums}->{ $prew }->{'UAH'}),
 				USD_FORMAT=>format_float($proto->{sums}->{ $prew }->{'USD'}),
 				EUR_FORMAT=>format_float($proto->{sums}->{ $prew }->{'EUR'}),
 				concl_color=>($proto->{sums}->{ $prew }->{'USD'}+$proto->{sums}->{ $prew }->{'UAH'}/$proto->{reports_rate}->{$prew}->{rr_rate} )>=-0.001
  			     };	
			
		push @$rows,{ct_ex_comis_type=>'transaction',ct_date=>format_date($prew),
		ct_currency=>'USD',orig__ct_currency=>'USD',ct_fid=>$credit_id,f_name=>'Credit',
		orig__ct_amnt=>$proto->{credit}->{sum},
		ct_amnt=>format_float($proto->{credit}->{sum}),
		ct_comment=>'Общая сумма начисленного штрафа',col_status=>'no'};

		
		
		
		

		@$rows=reverse(@$rows); 
		pop @{$proto->{fields}};
		$proto->{a_uah}=format_float($proto->{sums}->{ $prew }->{'UAH'});
   		$proto->{a_usd}=format_float($proto->{sums}->{ $prew }->{'USD'});
 		$proto->{a_eur}=format_float($proto->{sums}->{ $prew }->{'EUR'});
		$proto->{fin_uah}=format_float($proto->{sums}->{ $prew }->{'UAH'});
  		$proto->{fin_usd}=format_float($proto->{sums}->{ $prew }->{'USD'});
  		$proto->{fin_eur}=format_float($proto->{sums}->{ $prew }->{'EUR'});	
	}

	
}
sub sum_credit
{
	##$prev_row - in our case its date
	my ($array,$row,$prev_row,$proto)=@_;

	
	if(!$prev_row)
	{
		##if the first row begin our calculation
		my %hash;
		
		$proto->{sums}->{ $row->{ct_date} }=\%hash;
		$proto->{sums}->{ $row->{ct_date} }->{'UAH'}=$proto->{orig__beg_uah};
		$proto->{sums}->{ $row->{ct_date} }->{'USD'}=$proto->{orig__beg_usd};
		$proto->{sums}->{ $row->{ct_date} }->{'EUR'}=$proto->{orig__beg_eur};
		$proto->{sums}->{ $row->{ct_date} }->{'BTC'}=$proto->{orig__beg_btc};

		$proto->{reports_rate}->{ $row->{ct_date} }={rr_rate=>5.05} unless( $proto->{reports_rate}->{ $row->{ct_date} });

        

        
		my $concl_sum=$proto->{"orig__beg_".lc($proto->{credit_currency})};

		my $days=abs(get_date_diff($proto->{beg_calc_date},$row->{ct_date}));
		if($concl_sum<0)
		{
				
				my $tm_sum=$days*($proto->{credit}->{day_percent}*$concl_sum);
				$tm_sum=ceil($tm_sum*100)/100;
				$proto->{credit}->{sum}+=$tm_sum;

		push @$array,{ct_ex_comis_type=>'transaction',ct_date=>format_date($proto->{beg_calc_date}),
		ct_currency=>$proto->{credit_currency},orig__ct_currency=>$proto->{credit_currency},ct_fid=>$credit_id,f_name=>'Credit',
		orig__ct_amnt=>$tm_sum,
		ct_amnt=>format_float($tm_sum),
		result_amnt=>$tm_sum,
		ct_comment=>qq[Начисление кредита за $days дня $proto->{credit_currency}],
		col_status=>'no'};
		
		}	
		

		push @$array,{ct_ex_comis_type=>'concl',ct_date=>format_date($row->{ct_date}),
 			      	UAH=>$proto->{sums}->{ $row->{ct_date} }->{'UAH'},
 			      	USD=>$proto->{sums}->{ $row->{ct_date} }->{'USD'},
                                EUR=>$proto->{sums}->{ $row->{ct_date} }->{'EUR'},
                                BTC=>$proto->{sums}->{ $row->{ct_date} }->{'BTC'},
				    
			        UAH_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'UAH'}),
			        USD_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'USD'}),
			        EUR_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'EUR'}),
                                BTC_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'BTC'}),

			        REPORT_UAH=>$proto->{sums}->{ $row->{ct_date} }->{'UAH'}/$proto->{reports_rate}->{ $row->{ct_date} }->{rr_rate},
			concl_color=>($proto->{sums}->{ $row->{ct_date} }->{'UAH'}/$proto->{reports_rate}->{$row->{ct_date} }->{rr_rate} +
				$proto->{sums}->{ $row->{ct_date} }->{'USD'})>=-0.001
 			     };
		
				
	}elsif(!$proto->{sums}->{$row->{ct_date}}){
		##if conclusion calculation for this date
		##
		my %hash;
		$proto->{sums}->{ $row->{ct_date} }=\%hash;
		$proto->{sums}->{ $row->{ct_date} }->{UAH}=$proto->{sums}->{ $prev_row }->{UAH};
		$proto->{sums}->{ $row->{ct_date} }->{USD}=$proto->{sums}->{ $prev_row }->{USD};
		$proto->{sums}->{ $row->{ct_date} }->{EUR}=$proto->{sums}->{ $prev_row }->{EUR};
                $proto->{sums}->{ $row->{ct_date} }->{BTC}=$proto->{sums}->{ $prev_row }->{BTC};

$proto->{reports_rate}->{ $row->{ct_date} }={rr_rate=>5} unless( $proto->{reports_rate}->{ $row->{ct_date} });
	
		
		
		###checkig whether the client have a negative balance
		my $concl_sum=$proto->{sums}->{ $row->{ct_date} }->{$proto->{credit_currency}};
		
		if($concl_sum<0)
		{
			
				my $days=abs(get_date_diff($prev_row,$row->{ct_date}));
				my $tm_sum=$days*($proto->{credit}->{day_percent}*$concl_sum);
				$tm_sum=ceil($tm_sum*100)/100;
				$proto->{credit}->{sum}+=$tm_sum;

				push @$array,{ct_ex_comis_type=>'transaction',ct_date=>format_date($prev_row),
				ct_currency=>$proto->{credit_currency},orig__ct_currency=>$proto->{credit_currency},
                ct_fid=>$credit_id,f_name=>'Credit',
				orig__ct_amnt=>$tm_sum,
				ct_amnt=>format_float($tm_sum),
				result_amnt=>$tm_sum,
				ct_comment=>qq[Начисление кредита за $days дня $proto->{credit_currency}],
				col_status=>'no'};
		
		}		


		

		push @$array,{ct_ex_comis_type=>'concl',ct_date=>format_date($row->{ct_date}),
 			      	UAH=>$proto->{sums}->{ $prev_row }->{UAH},
 			      	USD=>$proto->{sums}->{ $prev_row }->{USD},
				    EUR=>$proto->{sums}->{ $prev_row }->{EUR},
				    UAH_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'UAH'}),
				    USD_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'USD'}),
				    EUR_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'EUR'}),
				    REPORT_UAH=>$proto->{sums}->{ $row->{ct_date} }->{'UAH'}/$proto->{reports_rate}->{ 
				$row->{ct_date} }->{rr_rate},
				concl_color=>$concl_sum>=-0.001
 			     };	
	
	
	}
	if($row->{ct_ex_comis_type} eq 'simple')
	{
		$row->{currency2}=$row->{e_currency2};

		$row->{currency1}=$row->{orig__ct_currency};

		$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }-=$row->{ct_amnt};

		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{result_amnt};

		return;
		
	}
	if($row->{ct_ex_comis_type} eq 'transaction')
	{   
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{ct_amnt};
		return;
		
	}
	
 	unless($row->{ct_eid})
	{
 	
	$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{ct_amnt};

	$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{comission};

	$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{ct_ext_commission};
	

		
				

 		return;
		
 	}
	if($row->{ct_eid}&&$row->{ct_amnt}>0)
	{
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{result_amnt};
# 		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{ct_ext_commission};
		$row->{currency1}=$row->{orig__ct_currency};
		$row->{currency2}=$row->{e_currency2};
		return ;


	}
	else
	{	
		$row->{currency1}=$row->{e_currency2};
		$row->{currency2}=$row->{orig__ct_currency};

		$row->{search_url}="correctings.cgi?ct_id=$row->{ct_id}&amp;action=filter&ct_date=all_time";

 		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }-=$row->{result_amnt};
		return;
	}	
	

}


sub last_record
{
	my ($rows,$r,$prew,$proto)=@_;

	$proto->{reports_rate}->{$prew} ={rr_rate=>5.05} unless( $proto->{reports_rate}->{ $prew }); 
	$proto->{beg_uah}=$proto->{beg_uah};
  	$proto->{beg_usd}=$proto->{beg_usd};
  	$proto->{beg_eur}=$proto->{beg_eur};	
  	$proto->{beg_btc}=$proto->{beg_btc};	

	my $a_info=$dbh->selectrow_hashref(q[SELECT * FROM accounts WHERE a_id=?],undef,$proto->{'ct_aid'});

	unless( defined($prew) )   
	{
			
		$proto->{a_uah}=format_float($a_info->{a_uah});
   		$proto->{a_usd}=format_float($a_info->{a_usd});
 		$proto->{a_eur}=format_float($a_info->{a_eur});
 		$proto->{a_btc}=format_float($a_info->{a_btc});
		
		$proto->{non_a_uah}=$a_info->{a_uah};
   		$proto->{non_a_usd}=$a_info->{a_usd};
 		$proto->{non_a_eur}=$a_info->{a_eur};
                $proto->{non_a_btc}=$a_info->{a_btc};
                ##???!!
		$proto->{control_sum}=$a_info->{a_uah}+$a_info->{a_usd}+$a_info->{a_eur} + $a_info->{a_btc};
		
		$proto->{control_sum_exist}=$a_info->{a_uah}+$a_info->{a_usd}+$a_info->{a_eur}+$a_info->{a_btc};
		$proto->{control_sum_exist_fin}=$proto->{orig__beg_uah}+$proto->{orig__beg_usd}+$proto->{orig__beg_eur}+$proto->{orig__beg_btc};
		$proto->{fin_uah}=format_float($proto->{orig__beg_uah});
  		$proto->{fin_usd}=format_float($proto->{orig__beg_usd});
  		$proto->{fin_eur}=format_float($proto->{orig__beg_eur});		
  		$proto->{fin_btc}=format_float($proto->{orig__beg_btc});		
  		
	
	}else
	{

 		push @$rows,{ct_ex_comis_type=>'concl',ct_date=>"Итого :",
  			      	UAH=>	$proto->{sums}->{ $prew }->{'UAH'},
  			      	USD=>	$proto->{sums}->{ $prew }->{'USD'},
 				EUR=>	$proto->{sums}->{ $prew }->{'EUR'},
                                EUR=>	$proto->{sums}->{ $prew }->{'BTC'},

                                prev_date=>format_date($prew),
 				UAH_FORMAT=>format_float($proto->{sums}->{ $prew }->{'UAH'}),
 				USD_FORMAT=>format_float($proto->{sums}->{ $prew }->{'USD'}),
 				EUR_FORMAT=>format_float($proto->{sums}->{ $prew }->{'EUR'}),
                                BTC_FORMAT=>format_float($proto->{sums}->{ $prew }->{'BTC'}),

 				concl_color=>($proto->{sums}->{ $prew }->{'USD'}+$proto->{sums}->{ $prew }->{'UAH'}/$proto->{reports_rate}->{$prew}->{rr_rate} )>=-0.001
  			     };	
		@$rows=reverse(@$rows); 
		
		$proto->{a_uah}=format_float($a_info->{a_uah});
   		$proto->{a_usd}=format_float($a_info->{a_usd});
 		$proto->{a_eur}=format_float($a_info->{a_eur});
 		$proto->{a_btc}=format_float($a_info->{a_btc});
		
		$proto->{non_a_uah}=$a_info->{a_uah};
   		$proto->{non_a_usd}=$a_info->{a_usd};
 		$proto->{non_a_eur}=$a_info->{a_eur};
 		$proto->{non_a_btc}=$a_info->{a_btc};

		$proto->{control_sum_exist}=$a_info->{a_uah}+$a_info->{a_usd}+$a_info->{a_eur}+ $a_info->{a_btc} ;
		$proto->{control_sum_exist_fin}=$proto->{sums}->{ $prew }->{'UAH'}+$proto->{sums}->{ $prew }->{'USD'}+$proto->{sums}->{ $prew }->{'EUR'}+$proto->{sums}->{ $prew }->{'BTC'};



		$proto->{fin_uah}=format_float($proto->{sums}->{ $prew }->{'UAH'});
  		$proto->{fin_usd}=format_float($proto->{sums}->{ $prew }->{'USD'});
  		$proto->{fin_eur}=format_float($proto->{sums}->{ $prew }->{'EUR'});
                $proto->{fin_btc}=format_float($proto->{sums}->{ $prew }->{'BTC'});


	}

    
 




}
sub calculate_sum_with
{
	my $ref=shift;
	#$a_id $date1,$date2)
	$ref->{table}='accounts_reports_table'	unless($ref->{table});
	
	
#	die $ref->{table};
	 my $sth =$dbh->prepare(
	qq[
		  SELECT 
		  SQL_CALC_FOUND_ROWS * FROM $ref->{table}
		  WHERE ct_aid=? AND ct_status!='deleted'
		  AND $ref->{date1} 
		  AND $ref->{date2} ORDER BY ts ASC
	]);

#	die  qq[                                                                                                                               
#	                  SELECT                                                                                                                  
#			                    SQL_CALC_FOUND_ROWS * FROM $ref->{table}                                                                                
#					                      WHERE ct_aid=? AND ct_status!='deleted'                                                                                 
#							                        AND $ref->{date1}                                                                                                       
#										                  AND $ref->{date2} ORDER BY ts ASC                                                                                       
#												          ];

	 $sth->execute($ref->{a_id});
	 my $proto={};

#	$ref->{compare}=$dbh->selectrow_array(qq[SELECT TIME_TO_SEC('$ref->{date_from}')+TO_DAYS('$ref->{date_from}')*864000 ]);

	 my %hash;

	 $proto->{sums}=\%hash;		
	 #post formating
	 my $prev_row=undef;##for first row the prev row will be undef
	 my $r;
	 my @rows;
	while( $r = $sth->fetchrow_hashref)
	{
		     	#copied from CGIBASE but in light version 	       	
			##if  we defind a sub of working with te record
 			sum_(\@rows,$r,$prev_row,$proto,$ref->{compare});
			$prev_row=$r->{ct_date};

  	
	}

   	$sth->finish();	
	return  $proto->{sums}->{$prev_row};
}

sub calculate_sum
{
	my $ref=shift;
	#$a_id $date1,$date2)
	
	 my $sth =$dbh->prepare(
	qq[
		  SELECT 
		  SQL_CALC_FOUND_ROWS * FROM accounts_reports_table
		  WHERE ct_aid=? AND ct_fid NOT IN (-7,-8,30,33,34,35,744,745,668,669,670,767,766,768)
		  AND $ref->{date1} 
		  AND $ref->{date2} ORDER BY ts ASC
	]);


#	$ref->{compare}=$dbh->selectrow_array(qq[SELECT TIME_TO_SEC('$ref->{date_from}')+TO_DAYS('$ref->{date_from}')*864000 ]);
	 $sth->execute($ref->{a_id});
	 my $proto={};

	 my %hash;

	 $proto->{sums}=\%hash;		
	 #post formating
	 my $prev_row=undef;##for first row the prev row will be undef
	 my $r;
	 my @rows;
	 while( $r = $sth->fetchrow_hashref)
	 {
		     	#copied from CGIBASE but in light version 	       	
			##if  we defind a sub of working with te record
 			sum_(\@rows,$r,$prev_row,$proto,$ref->{compare});
			$prev_row=$r->{ct_date};

  	
	 }
   	$sth->finish();	
	return $proto->{sums}->{$prev_row};
}

#without filling the array
sub sum_
{
	my ($arr,$row,$prev_row,$proto,$compare)=@_;
		
	unless($prev_row)
	{
		##if the first row begin our calculation
		my %hash;
		$proto->{sums}->{ $row->{ct_date} }=\%hash;
		$proto->{sums}->{ $row->{ct_date} }->{'UAH'}=0;
		$proto->{sums}->{ $row->{ct_date} }->{'USD'}=0;
		$proto->{sums}->{ $row->{ct_date} }->{'EUR'}=0;
                $proto->{sums}->{ $row->{ct_date} }->{'BTC'}=0;
		$proto->{sums}->{ $row->{ct_date} }->{'GBP'}=0;
                $proto->{sums}->{ $row->{ct_date} }->{'RUB'}=0;

		$proto->{reports_rate}->{ $row->{ct_date} }={rr_rate=>25} unless( $proto->{reports_rate}->{ $row->{ct_date} });
		
	}
	

	
	unless($proto->{sums}->{$row->{ct_date}})
	{
		##if conclusion calculation for this date
		##
		my %hash;
		$proto->{sums}->{ $row->{ct_date} }=\%hash;
		$proto->{sums}->{ $row->{ct_date} }->{UAH}=$proto->{sums}->{ $prev_row }->{UAH};
		$proto->{sums}->{ $row->{ct_date} }->{USD}=$proto->{sums}->{ $prev_row }->{USD};
		$proto->{sums}->{ $row->{ct_date} }->{EUR}=$proto->{sums}->{ $prev_row }->{EUR};
		$proto->{sums}->{ $row->{ct_date} }->{BTC}=$proto->{sums}->{ $prev_row }->{BTC};
		$proto->{sums}->{ $row->{ct_date} }->{GBP}=$proto->{sums}->{ $prev_row }->{GBP};
		$proto->{sums}->{ $row->{ct_date} }->{RUB}=$proto->{sums}->{ $prev_row }->{RUB};

		push 	@$arr,$proto->{sums}->{ $prev_row };

		$proto->{reports_rate}->{ $row->{ct_date} }={rr_rate=>25.05} unless( $proto->{reports_rate}->{ $row->{ct_date} });

	
	
	}
        return	if($row->{ct_status} eq 'deleted');
	
 
	
	if($row->{ct_ex_comis_type} eq 'simple')
	{
# 		die $row->{ct_amnt};

	
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{ct_currency} }-=$row->{ct_amnt};
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{result_amnt};
		$row->{ct_amnt}=-$row->{ct_amnt};
		return;
		
	}
	
	if($row->{ct_ex_comis_type} eq 'transaction')
	{
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{ct_currency} }+=$row->{ct_amnt};
		

        return;
		
	}
	unless($row->{ct_eid})
	{
 	
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{ct_currency} }+=$row->{ct_amnt};

		$proto->{sums}->{ $row->{ct_date} }->{ $row->{ct_currency} }+=$row->{comission};

		$proto->{sums}->{ $row->{ct_date} }->{ $row->{ct_currency} }+=$row->{ct_ext_commission};

	
 		return;
		
 	}
	if($row->{ct_eid}&&$row->{ct_amnt}>0)
	{
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{result_amnt};
# 		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{ct_ext_commission};

	}
	else
	{	
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }-=$row->{result_amnt};
	}	
	return;
	
	
}
sub last_record_doc{
        my ($array,$row,$prev_row,$proto)=@_;



}
sub  sum_doc{
   my  ($array,$row,$prev_row,$proto)=@_;

#        <td style="width:6em" class=table_gborders>Дата </td>
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
#         <td style="width:12em" class=table_gborders>$row.comment<!--Примечания--> </td>
#         <td style="width:12em" class=table_gborders>$row.from<!--От кого--> </td>
    




}
sub generate_set_of_dates_array{
    my ($from_day,$from_month,$from_year,$format)=@_;
    my $day=(localtime)[3];
    my $month=(localtime)[4]+1;
    my $year=(localtime)[5]+1900;
    my $desc=$year-$from_year;
    my $month_desc;
    my $month_to;
    my $to_d;
    my @res;
    
    my %zero_fil=(
    1=>'01',
    2=>'02',
    3=>'03',
    4=>'04',
    5=>'05',
    6=>'06',
    7=>'07',
    8=>'08',
    9=>'09',
    10=>'10',
    11=>'11',
    12=>'12',
    13=>'13',
    14=>'14',
    15=>'15',
    16=>'16',
    17=>'17',
    18=>'18',
    19=>'19',
    20=>'20',
    21=>'21',
    22=>'22',
    23=>'23',
    24=>'24',
    25=>'25',
    26=>'26',
    27=>'27',
    28=>'28',
    29=>'29',
    30=>'30',
    31=>'31',
    );
    

    for(my $y=0;$y<=$desc;$y++){
#         print "$y\n";
        if($y==0){
                    
           $month_desc=$from_month;
           
        }else{
            $month_desc=1;
            $from_year+=1;
              
        }
     
       if($from_year==$year){
            $month_to=$month;
        
        }else{
           $month_to=12; 
        }
    
       
        for(;$month_desc<=$month_to;$month_desc++){
        
            $to_d=$months_days{$month_desc};
            $to_d=29  if($month_desc==2&&(($y+$from_year) % 4)==0);###for every 4 year
          
          if($from_year==$year&&$month_to==$month_desc){
                $to_d=$day;
            }
            my $i=1;
            $i=$from_day if($month_desc==$from_month);
            for(;$i<=$to_d;$i++){
                    push  @res,$from_year."-".$zero_fil{$month_desc}."-".$zero_fil{$i};
            }


        }



    }
    return  \@res;
}

### add color for btc
sub sum
{
	##$prev_row - in our case its date
	my ($array,$row,$prev_row,$proto)=@_;

	
	unless($prev_row)
	{
		##if the first row begin our calculation
		my %hash;
		
		$proto->{sums}->{ $row->{ct_date} }=\%hash;
		$proto->{sums}->{ $row->{ct_date} }->{'UAH'}=$proto->{orig__beg_uah};
		$proto->{sums}->{ $row->{ct_date} }->{'USD'}=$proto->{orig__beg_usd};
		$proto->{sums}->{ $row->{ct_date} }->{'EUR'}=$proto->{orig__beg_eur};
		$proto->{sums}->{ $row->{ct_date} }->{'BTC'}=$proto->{orig__beg_btc};
                $proto->{sums}->{ $row->{ct_date} }->{'GBP'}=$proto->{orig__beg_gbp};
		$proto->{sums}->{ $row->{ct_date} }->{'RUB'}=$proto->{orig__beg_rub};
        
		$proto->{reports_rate}->{ $row->{ct_date} }={rr_rate=>5.05} unless( $proto->{reports_rate}->{ $row->{ct_date} });

		push @$array,{ct_ex_comis_type=>'concl',ct_date=>format_date($row->{ct_date}),
 			      	UAH=>$proto->{sums}->{ $row->{ct_date} }->{'UAH'},
 			      	USD=>$proto->{sums}->{ $row->{ct_date} }->{'USD'},
				EUR=>$proto->{sums}->{ $row->{ct_date} }->{'EUR'},
				BTC=>$proto->{sums}->{ $row->{ct_date} }->{'BTC'},
                                GBP=>$proto->{sums}->{ $row->{ct_date} }->{'GBP'},
				RUB=>$proto->{sums}->{ $row->{ct_date} }->{'RUB'},

				UAH_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'UAH'}),
				USD_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'USD'}),
				EUR_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'EUR'}),
				BTC_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'BTC'}),
				GBP_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'GBP'}),
				RUB_FORMAT=>format_float($proto->{sums}->{ $row->{ct_date} }->{'RUB'}),
				
 				REPORT_UAH=>
				$proto->{sums}->{ $row->{ct_date} }->{'UAH'}/$proto->{reports_rate}->{ $row->{ct_date} }->{rr_rate},
				concl_color=>($proto->{sums}->{ $row->{ct_date} }->{'UAH'}/$proto->{reports_rate}->{$row->{ct_date} }->{rr_rate} +
				$proto->{sums}->{ $row->{ct_date} }->{'USD'})>=-0.001
                

 			     };
		
				
	}
	

	
	unless($proto->{sums}->{$row->{ct_date}})
	{
		##if conclusion calculation for this date
		
		
 	
	
		##
		my %hash;
		$proto->{sums}->{ $row->{ct_date} }=\%hash;
		$proto->{sums}->{ $row->{ct_date} }->{UAH}=$proto->{sums}->{ $prev_row }->{UAH};
		$proto->{sums}->{ $row->{ct_date} }->{BTC}=$proto->{sums}->{ $prev_row }->{BTC};
		$proto->{sums}->{ $row->{ct_date} }->{USD}=$proto->{sums}->{ $prev_row }->{USD};
		$proto->{sums}->{ $row->{ct_date} }->{EUR}=$proto->{sums}->{ $prev_row }->{EUR};
		$proto->{sums}->{ $row->{ct_date} }->{GBP}=$proto->{sums}->{ $prev_row }->{GBP};
		$proto->{sums}->{ $row->{ct_date} }->{RUB}=$proto->{sums}->{ $prev_row }->{RUB};
		
		
		
	    $proto->{reports_rate}->{ $row->{ct_date} }={rr_rate=>5.05} unless( $proto->{reports_rate}->{ $row->{ct_date} });

		push @$array,{ct_ex_comis_type=>'concl',
                    non_format_date=>$row->{ct_date},
                    prev_date=>format_date($prev_row),ct_date=>format_date($row->{ct_date}),
 			      	UAH=>$proto->{sums}->{ $prev_row }->{UAH},
 			      	USD=>$proto->{sums}->{ $prev_row }->{USD},
 			      	BTC=>$proto->{sums}->{ $prev_row }->{BTC},
                                GBP=>$proto->{sums}->{ $prev_row }->{GBP},
 			      	RUB=>$proto->{sums}->{ $prev_row }->{RUB},

				    EUR=>$proto->{sums}->{ $prev_row }->{EUR},
				    UAH_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'UAH'}),
				    BTC_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'BTC'}),
				    USD_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'USD'}),
				    EUR_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'EUR'}),
                                    GBP_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'GBP'}),
				    RUB_FORMAT=>format_float($proto->{sums}->{ $prev_row }->{'RUB'}),

                                    DEBT_FORMAT=>$proto->{docs}->{ $prev_row }->{all},
				    REPORT_UAH=>$proto->{sums}->{ $row->{ct_date} }->{'UAH'}/$proto->{reports_rate}->{ 
				    $row->{ct_date} }->{rr_rate},
				    concl_color=>($proto->{sums}->{ $row->{ct_date} }->{'UAH'}/$proto->{reports_rate}->{ 
				    $row->{ct_date} }->{rr_rate}+$proto->{sums}->{ $row->{ct_date} }->{'USD'})>=-0.001,
                    comment=>$proto->{dates_comment}->{ $row->{ct_date} }->{comment}
 			     };	
	
	
	}
	$row->{col_color}=sprintf('#%x',$row->{col_color});




	if($row->{ct_status} eq 'deleted')
 	{
		
		if($row->{ct_ex_comis_type} eq 'simple')
		{
			$row->{currency2}=$row->{e_currency2};
			$row->{currency1}=$row->{orig__ct_currency};
		}elsif($row->{ct_eid})
		{
			$row->{currency1}=$row->{e_currency2};
			$row->{currency2}=$row->{orig__ct_currency};
		
		}
		$row->{ct_amnt}=-$row->{ct_amnt} if($row->{ct_ex_comis_type} eq 'simple');

 	    push @$array,$row;
 	    
	    return;
 	}
	
	##for slavik
        #if($row->{ct_ex_comis_type} eq 'simple')
	#{
	  
	#     return;  
	 #use Data::Dumper;
	 #  die Dumper $row;
	#}

	
	if($row->{ct_ex_comis_type} eq 'simple')
	{
# 		die $row->{ct_amnt};
		$row->{currency2}=$row->{e_currency2};

		$row->{currency1}=$row->{orig__ct_currency};

		$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }-=$row->{ct_amnt};

		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{result_amnt};

		$row->{ct_amnt}=-$row->{ct_amnt};

	    $row->{search_url}="exc.cgi?e_id=$row->{ct_id}&amp;action=filter&amp;do=list&t_ts1=this_year";
	
		push @$array,$row;
		return;
		
	}
	if($row->{ct_ex_comis_type} eq 'transaction')
	{
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{ct_amnt};

	    $row->{search_url}="trans.cgi?t_id=$row->{ct_id}&amp;action=filter&amp;t_date=this_year";
	
		push @$array,$row;				
		return;
		
	}
	
 	unless($row->{ct_eid})
	{
 	
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{ct_amnt};

		$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{comission};

		$proto->{sums}->{ $row->{ct_date} }->{ $row->{orig__ct_currency} }+=$row->{ct_ext_commission};
	

#       must rewrited
# 		if($row->{orig__ct_fid}==-1&&$row->{orig__ct_amnt}<0)
# 		{
# 	
# 			$row->{search_url}="cashier_output2.cgi?ct_id=$row->{ct_id}&amp;action=filter&ct_date=this_year";
# 		
# 		}elsif($row->{orig__ct_fid}==-1&&$row->{orig__ct_amnt}>0)
# 		{
# 	
# 		    $row->{search_url}="cashier_input.cgi?ct_id=$row->{ct_id}&amp;action=filter&ct_date=this_year";
# 	
# 			
# 		}
        if($row->{orig__ct_amnt}>0&&$row->{orig__ct_fid}>0)
		{
			
		    $row->{search_url}="correctings.cgi?ct_id=$row->{ct_id}&amp;action=filter&ct_date=this_year";
			
		}else
		{
		    $row->{search_url}="correctings.cgi?ct_id=$row->{ct_id}&amp;action=filter&ct_date=this_year";
		}
	
 		push @$array,$row;				

 		return;
		
 	}
	if($row->{ct_eid}&&$row->{ct_amnt}>0)
	{
		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{result_amnt};
# 		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }+=$row->{ct_ext_commission};
		$row->{currency1}=$row->{orig__ct_currency};
		$row->{currency2}=$row->{e_currency2};

		$row->{search_url}="correctings.cgi?ct_id=$row->{ct_id}&amp;action=filter&ct_date=this_year";

		push @$array,$row;

	}
	else
	{	
		$row->{currency1}=$row->{e_currency2};
		$row->{currency2}=$row->{orig__ct_currency};

		$row->{search_url}="correctings.cgi?ct_id=$row->{ct_id}&amp;action=filter&ct_date=this_year";

 		$proto->{sums}->{ $row->{ct_date} }->{ $row->{e_currency2} }-=$row->{result_amnt};
		push @$array,$row;
		return;
	}	
	

}

##for calculating accounts_reports
sub get_exchanges_cash
{
	my $uah=$dbh->selectrow_array(q[SELECT r_rate 
					FROM rates 
					WHERE 
					r_currency1='UAH' AND r_currency2='USD' 
					AND r_type='cash'
					ORDER BY r_ts DESC LIMIT 0,1]);
	$uah=5.05 unless($uah);
	
	my $eur=$dbh->selectrow_array(q[SELECT r_rate 
					FROM rates 
					WHERE r_currency1='EUR'
					 AND r_currency2='USD' 
					AND r_type='cash'
					ORDER BY r_ts DESC LIMIT 0,1]);
	$eur=1.47 unless($eur);

	my $rates={UAH=>$uah,USD=>1,EUR=>$eur};
 	
	return $rates;
}
sub get_whole_exchanges
{
 	
	my $uah=$dbh->selectrow_array(q[SELECT r_rate 
					FROM rates 
					WHERE r_currency1='UAH' AND r_currency2='USD' 
					AND r_type='cashless'
					ORDER BY r_ts DESC
                                        LIMIT 0,1]);
	$uah=5.05 unless($uah);
	
	my $eur=$dbh->selectrow_array(q[SELECT r_rate 
					FROM rates 
					WHERE r_currency1='EUR'
					 AND r_currency2='USD' 
					AND r_type='cashless'
                                        ORDER BY r_ts DESC LIMIT 0,1]);
	$eur=1.47 unless($eur);
        
        my $rates={UAH_USD=>$uah,USD_USD=>1,EUR_USD=>$eur};

       
        
         $uah=$dbh->selectrow_array(q[SELECT r_rate 
					FROM rates 
					WHERE r_currency1='USD' AND r_currency2='UAH' 
					AND r_type='cashless'
					ORDER BY r_ts DESC
                                        LIMIT 0,1]);
	$uah=5.05 unless($uah);
	
	$eur=$dbh->selectrow_array(q[SELECT r_rate 
					FROM rates 
					WHERE r_currency1='EUR'
					 AND r_currency2='UAH' 
					AND r_type='cashless'
                                        ORDER BY r_ts DESC LIMIT 0,1]);
	$eur=1.47 unless($eur);
        $rates->{USD_UAH}=$uah;
        $rates->{EUR_UAH}=$eur;
        $rates->{UAH_UAH}=1;
        
         $uah=$dbh->selectrow_array(q[SELECT r_rate 
					FROM rates 
					WHERE r_currency1='USD' AND r_currency2='EUR' 
					AND r_type='cashless'
					ORDER BY r_ts DESC
                                        LIMIT 0,1]);
	$uah=5.05 unless($uah);
	
	$eur=$dbh->selectrow_array(q[SELECT r_rate 
					FROM rates 
					WHERE r_currency1='UAH'
					 AND r_currency2='EUR' 
					AND r_type='cashless'
                                        ORDER BY r_ts DESC LIMIT 0,1]);
	$eur=1.47 unless($eur);
        $rates->{USD_EUR}=$uah;
        $rates->{UAH_EUR}=$eur;
        $rates->{EUR_EUR}=1;
        my ($from,$to);
        foreach( keys %$rates)
        {
            ($from,$to)=split('_',$_);
             $rates->{lc($_)}=pow($rates->{$_},$RATE_FORMS{$from}->{$to});
        }
	
        return $rates;
}
sub get_exchanges
{
 	
	my $uah=$dbh->selectrow_array(q[SELECT r_rate 
					FROM rates 
					WHERE r_currency1='UAH' AND r_currency2='USD' 
					AND r_type='cashless'
					ORDER BY r_ts DESC LIMIT 0,1]);
	$uah=5.05 unless($uah);
	
	my $eur=$dbh->selectrow_array(q[SELECT r_rate 
					FROM rates 
					WHERE r_currency1='EUR'
					 AND r_currency2='USD' 
					AND r_type='cashless'
					ORDER BY r_ts DESC LIMIT 0,1]);
	$eur=1.47 unless($eur);

	my $rates={UAH=>$uah,USD=>1,EUR=>$eur};
 	
	return $rates;
}
sub format_date
{
	my $str=shift;
	$str=~/(\d{1,4})-(\d{1,2})-(\d{1,2})/;
	return "$3.$2.$1";
}
sub format_datetime_month_year
{
    my $str=shift;
    $$str=~/(\d{1,4})-(\d{1,2})-(\d{1,2})/;
    $$str=$months{$2}." $1 ";

}

sub format_datetime
{
	my $str=shift;
	$str=~/(\d{1,4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/;
	return "$3.$2.$1 $4:$5";
}
sub format_float_inner
{
	my $f=shift;
	
	$f=~s/[,]/\./;
	$f=~s/[ \t]//g;
	
	return 0 if(abs($f)<0.0001);
	return $f*1;
	
}
sub normal_prec
{
    my $amnt=shift;
    $amnt=ceil($amnt*100)/100;
  return $amnt;
  
}
sub andrey_float_format
{
    my $f=shift;
    $f=normal_prec($f);
    
#    $f=~s/(\d{1,3})(?=\d{3})/$1 /g;
    $f=~s/(\d{1,3})(?=((\d{3})+)\D?)/$1 /g;
    return $f;
}

sub format_float
{
	my $f=shift;
	$f=format_float_inner($f);
	return 0 if(abs($f)<0.0001);
	
	$f=normal_prec($f);
	
	$f=~/([\-])?(\d+)\.(\d{1,2})$|([\-])?(\d+)/;
	
	my $d='';
	my $mines='';
		
        unless($3)
	{	
		$f=$5;
		$mines=$4;
	}else
	{
		$mines=$1;
		$d=".$3";
		$f=$2;
	}
	my @ar=split(//,$f);
	my $size=@ar;
	my $i=0 ;
	my $res;
	my $j=0;
	$res.="$d";
	for($i=$size-1;$i>=0;$i--)
	{
    		unless($j)
		{
    			$res=$ar[$i].$res; 
			$j++;
		}else
		{
	    			$res=' '.$res unless($j%3);
				$res=$ar[$i].$res; 
				$j++;
		}
		
	} 
	return $mines.$res;
	
}
sub lowpow
{
   	
   my ($num,$pow)=@_;

   return $num**pow;
}
sub pow
{
   	
   my ($num,$pow)=@_;
   if($num==0)	 
	{	  
		return 0;
	}	
   my $ret=1;
   	if($pow<0)
	{		
		for(my $i=$pow;$i!=0;$i++)
		{
			$ret=$ret/$num;
		
		}
	}else
	{
		for(my $i=$pow;$i!=0;$i--)
		{
			$ret=$ret*$num;
		
		}
	}
   return $ret;
}

sub get_firms
{
	my $sth=$dbh->prepare(qq[SELECT
				*    FROM 
			firms ORDER BY f_name ASC]);
	my @res;
	$sth->execute();
	while(my $s=$sth->fetchrow_hashref())
	{
	
	
		push @res,$s;
	}
	$sth->finish();
	return \@res;
}
sub get_cache_connection
{
	
	require  Cache::Memcached::Fast;

	my $ref=new Cache::Memcached::Fast(
		{
		servers =>[{ address => '127.0.0.1:11211',weight=>2.5}],
		namespace => 'sessions:',
		connect_timeout => 0.2,
		io_timeout => 0.5,
		close_on_error => 1,
		compress_threshold =>-1,
		ketama_points => 150,
		nowait => 1,
		hash_namespace => 1,
		serialize_methods => [ \&Storable::freeze, \&Storable::thaw ]
		}
		);

	return $ref;

}
sub get_desc_rights_array
{
     require Storable;
             my $tabs;              
         my $md=get_cache_connection();
	 
	 
	if( 0 and $tabs=$md->get('name_tabs')){ 
		  my @arr;
              map { push @arr,$tabs->{$_} } keys %$tabs;
                   return \@arr;
	    }else{
                 $tabs=$DEF_TABS;
                 $md->set('name_tabs',$tabs);
	
		my @arr;
	    map { push @arr,$tabs->{$_} } keys %$tabs;
	
	     return \@arr;          

    }


}
sub get_desc_rights
{
#	require Storable;
	my $tabs;
	my $md=get_cache_connection();
	
	$tabs=$md->get('name_tabs');
	
	
	
	
	if( 0 and $tabs=$md->get('name_tabs'))
	{
	
		return $tabs;
		
	}	
	else
	{
		$tabs=$DEF_TABS;
		$md->set('name_tabs',$tabs);
	}

	return $tabs;

}
sub get_transit_list
{
	 my $ref=shift;
        $ref->{page}=$ref->{page}*$ref->{how};
        my $sth=$dbh->prepare(qq[SELECT SQL_CALC_FOUND_ROWS 
				*    FROM 
			transit_view WHERE   $ref->{'filter'}  ORDER BY ts DESC LIMIT].qq[ $ref->{'page'},$ref->{'how'}]);
	
	
        my @res;
        $sth->execute();
        my $count_pages=$dbh->selectrow_array(q[SELECT found_rows() ]);
        while(my $s=$sth->fetchrow_hashref())
        {

		
   		$s->{amnt}=format_float(abs($s->{amnt}));

               $s->{color_set}=$ref->{color_set}; 
               push @res,$s;

        }
      #  use Data::Dumper;
      #  die Dumper \@res;
        $sth->finish();
	
        return {transes=>\@res,count_pages=>$count_pages};
}
sub get_trans_list
{
        my $ref=shift;
        #my ($filter,$page,$how)=@_;
        
        $ref->{page}=$ref->{page}*$ref->{how};

      
         my $sth=$dbh->prepare(qq[SELECT SQL_CALC_FOUND_ROWS 
					t_id,
					t_ts_mysql,
					t_ts,
					t_aid1,
					t_aid2,
					t_amnt,
					t_currency,
					t_comment,
					t_oid,
					a_name1,
					a_name2,
					o_login,
					t_aid1$ref->{color} AS color
        FROM trans_view WHERE   $ref->{'filter'}  ORDER BY t_id DESC LIMIT].qq[ $ref->{'page'},$ref->{'how'}]);
	
	
        my @res;
        $sth->execute();
	
	my $count_pages=$dbh->selectrow_array(q[SELECT found_rows() ]);
        while(my $s=$sth->fetchrow_hashref())
        {


                if($s->{t_aid1}==$firms_id)
                {
                        $s->{firm1}=1;                  
                        my ($id,$name)=get_firm($s->{t_id});                    
                        $s->{firm1_id}=$id;
                        $s->{firm1_name}=$name;
        
                }
                if($s->{t_aid2}==$firms_id)
                {
                        $s->{firm2}=1;
                        my ($id,$name)=get_firm($s->{t_id});
                        $s->{firm2_id}=$id;
                        $s->{firm2_name}=$name;
        
                }               
              
                       
                   $s->{color_set}=$ref->{color_set}; 
		$s->{t_amnt}=format_float($s->{t_amnt});
                push @res,$s;
                
        }
      #  use Data::Dumper;
      #  die Dumper \@res;
        $sth->finish();
	
        return {transes=>\@res,count_pages=>$count_pages};
}
sub get_firm
{
        my $id=shift;
        return  $dbh->selectrow_array(q[SELECT f_id,f_name FROM cashier_transactions,firms WHERE ct_tid2=? AND ct_fid=f_id],undef,$id);
}
# subs ###############################################
sub get_card_percent_serivce
{
	my ($aid,$service_id)=@_;
	return $dbh->selectrow_array('SELECT cs_percent FROM client_services WHERE cs_fsid=? AND cs_aid=? ORDER cs_ts ESC  LIMIT 1',undef,$service_id,$aid);


}
sub get_info_of_trans
{
	my $id=shift;
	return $dbh->selectrow_hashref(q[SELECT * FROM cashier_transactions WHERE ct_id=? ],undef,$id);
}
sub get_account_name
{
    my $id=shift;
    my $sql = qq[SELECT * FROM accounts_view
       WHERE a_status='active' AND a_id=?
       ];
    my $r=$dbh->selectrow_hashref($sql,undef,$id);
        return {account_id=>$r->{f_id},account_title=>"$r->{a_name} (id#$r->{a_id})",ext_info=>
    "$r->{a_name} (id#$r->{a_id}) [$r->{a_class}] $r->{a_uah} ГРН ", 
# $r->{a_usd} USD, $r->{a_eur} EUR",
    eur=>$r->{a_eur},usd=>$r->{a_usd},uah=>$r->{a_uah},ac_id=>$r->{ac_id},a_incom_id=>$r->{a_incom_id}
    };

}
sub  get_service_name
{
	my $id=shift;
	my $sql = qq[SELECT * FROM firm_services
       WHERE fs_status='active' AND fs_id=?
       ];
	my $r=$dbh->selectrow_hashref($sql,undef,$id);
        return {service_id=>$r->{fs_id},service_title=>"$r->{fs_name} (id#$r->{fs_id})"
	};


}




sub get_firm_name
{
	my $id=shift;
	my $sql = qq[SELECT * FROM firms
       WHERE f_status='active' AND f_id=?
       ];
	my $r=$dbh->selectrow_hashref($sql,undef,$id);
    
	return {f_percent=>$r->{f_percent},firm_id=>$r->{f_id},firm_title=>"$r->{f_name} (id#$r->{f_id})",ext_info=>
	"$r->{f_name} (id#$r->{f_id}) ".format_float($r->{f_uah}).' ГРН ',
# 	.format_float($r->{f_usd}).' USD,'
# 	.format_float($r->{f_eur}).' EUR',
	f_uah=>$r->{f_uah},
	f_usd=>$r->{f_usd},
	f_eur=>$r->{f_eur},f_isres=>$r->{f_isres}
	};


}
sub get_cash_trans_sum
{
	my $id=shift;
	return	$dbh->selectrow_array('SELECT ct_amnt FROM cashier_transactions  WHERE ct_id=?',undef,$id);
}
sub trim {
    @_ = @_ ? @_ : $_ if defined wantarray;
    
    for (@_ ? @_ : $_) { s/\A\s+//; s/\s+\z// }

    return wantarray ? @_ : "@_";
}





sub get_firm_services_percents
{
	my $fid=shift;
	
	my $rf = $dbh->selectrow_hashref("SELECT * FROM firms WHERE f_id =? ",undef,$fid);
	my ($services,$slist);
	if($rf){
                $services = set2hash($rf->{f_services});
		$services->{'0'}=1;##for forward mysql query 
		
         	$slist=join(',',keys(%$services)); 
	}else{
		return undef;
	}
	
	my $ref=$dbh->selectall_arrayref(qq[SELECT fs_name,fs_id FROM firm_services 
		WHERE  
		fs_status='active' AND fs_id IN($slist) AND fs_id>0 ]);	
	my @res;
	map {push @res,{fs_name=>$_->[0],fs_id=>$_->[1],percent=>$_->[2]}} @$ref;
	return \@res;
	
}
sub get_service_percent_client{
    my $id=shift;
    my $service_id=shift;
    return $dbh->selectrow_array(q[
            SELECT cs_percent 
            FROM client_services 
            WHERE cs_aid=?  AND cs_fsid=? ORDER BY cs_ts DESC LIMIT 1 ],undef,$id,$service_id);    
  
}

sub get_services_percents_client{
	my $id=shift;
	my $ref=$dbh->selectall_arrayref(q[
			SELECT fs_name,fs_id,cs_percent FROM firm_services,client_services 
            WHERE cs_aid=? AND fs_status='active' AND cs_fsid=fs_id AND fs_id>0 
            AND  cs_month=MONTH(current_timestamp) AND cs_year=YEAR(current_timestamp)
            ],undef,$id);	
	my @res;
	map {push @res,{fs_name=>$_->[0],fs_id=>$_->[1],percent=>$_->[2]}} @$ref;
	return \@res;
	
}
#not used anywhere
sub get_client_services_percents
{
    my $fs_id=shift;
    
    my $ref=$dbh->selectall_arrayref(q[SELECT 
                      fs_id,cs_aid as a_id,cs_percent 
                      FROM client_services,firm_services 
                      WHERE 
                      cs_fsid=fs_id 
                      AND fs_status='active' 
                      AND fs_id=?
                      AND  cs_month=MONTH(current_timestamp) AND cs_year=YEAR(current_timestamp)
                        ],undef,$fs_id);

    my @res;
    
    map {push @res,{fs_id=>$_->[0],a_id=>$_->[1],cs_percent=>$_->[2]} } @$ref;
    
    return \@res;
}
sub get_special_services
{
	my @arr=@_;
	my $str=join(',',@arr);
	

	my $ref=$dbh->selectall_arrayref(qq[SELECT fs_name,fs_id FROM firm_services 
		WHERE  
		fs_status='active' AND fs_id IN($str) AND fs_id>0 ]);	
	my @res;
	push @res,{fs_name=>'Выберите услугу',fs_id=>''};
	map {push @res,{fs_name=>$_->[0],fs_id=>$_->[1],percent=>$_->[2]}} @$ref;

	return \@res;
	
}

sub get_services_percents
{

	my $ref=$dbh->selectall_arrayref(q[
			SELECT fs_id,fs_name,c_id,c_name,sc_percent
	   		FROM 
	  		firm_services,services_class,classes 
	  		WHERE fs_id=sc_fsid  AND sc_cid=c_id AND fs_status='active' AND fs_id>0
			ORDER BY fs_id
					]);

	my %hash;
	foreach(@$ref)
	{
		unless($hash{$_->[2]})
		{
			my %hash1;
			$hash1{$_->[0]}=$_->[4];
			$hash{$_->[2]}=\%hash1;
		}else
		{
			$hash{$_->[2]}->{$_->[0]}=$_->[4];
	
		}
	
	}
	my @res;
	foreach(keys %hash)
	{
		my @arr;
		foreach my $tmp (keys %{$hash{$_}})
		{
			push @arr,{fs_id=>$tmp,percent=>$hash{$_}->{$tmp}};		
			
		}
		push @res,{services=>\@arr,c_id=>$_};		
	}
	return \@res;	
}
sub get_static_plugins{
    my $self=shift;
    my $hash=$dbh->selectall_hashref(q[SELECT p_id as value,p_name as title FROM plugins WHERE 1],'value');
    my @res=();
    foreach(keys %$hash){
        push @res,$hash->{$_};
    }
    return  \@res;
}

sub get_cash_services{
    my $cash=shift;

    my $hash=$dbh->selectrow_array(q[SELECT f_services FROM firms WHERE f_id=?],undef,$cash);
    my $ref=set2hash($hash);
    my $str=join(',',keys %$ref);
    my $keys=$dbh->selectall_hashref(qq[SELECT fs_name as title,fs_id as value FROM firm_services WHERE fs_id in ($str)],'value');
    my @arr;
    foreach(keys %$keys){
        push @arr,$keys->{$_}

    }
    return \@arr;
    

    
    
}
sub get_services
{
	my $hash=$dbh->selectall_hashref(q[SELECT fs_id,fs_name FROM firm_services WHERE fs_status='active' AND fs_id>0],'fs_id');
	my @arr;
	map {push @arr,{fs_id=>$hash->{$_}->{fs_id},fs_name=>$hash->{$_}->{fs_name},value=>$hash->{$_}->{fs_id},title=>$hash->{$_}->{fs_name}}} keys %$hash;
	return \@arr;
}

sub get_classes
{
	  my $ref_cash=$dbh->selectall_arrayref("SELECT 1,c_id,c_name,c_ts FROM classes WHERE 1 ORDER BY c_name");
	  my @arr;
	  map{ push @arr,{value=>$_->[2],title=>$_->[2],c_status=>$_->[0],c_id=>$_->[1],c_name=>$_->[2],c_ts=>$_->[3]} } @$ref_cash;
	  return \@arr;
}

sub get_client_classes
{
	  my $fs_id=shift;

	  my $ref_cash=$dbh->selectall_arrayref("SELECT c_id,c_name,sc_percent FROM classes,services_class,firm_services
          WHERE c_id=sc_cid AND fs_id=sc_fsid AND fs_status!='deleted' AND fs_id=? ORDER BY c_name",undef,$fs_id);
	  my  @arr;
	  map {push @arr,{c_id=>$_->[0],c_name=>$_->[1],sc_percent=>$_->[2]}} @$ref_cash;
          return \@arr;
}

sub get_rates
{
        my $where=" AND  r_type='cash' ";
        my $ref_cash=$dbh->selectall_hashref("SELECT * FROM rates WHERE 1  $where",
        'r_currency1');
        $where=" AND  r_type='cashless' ";
        my $ref_cash_less=$dbh->selectall_hashref("SELECT * FROM rates WHERE 1 $where",'r_currency1');
        my (@rate_cash_less,@rate_cash);
        foreach( keys %$ref_cash_less)
        {
        
                push @rate_cash_less,{from=>$ref_cash_less->{$_}->{r_currency1},to=>$ref_cash_less->{$_}->{r_currency2},rate=>to_prec6(pow($ref_cash_less->{$_}->{r_rate},$RATE_FORMS{$ref_cash_less->{$_}->{r_currency1}}->{$ref_cash_less->{$_}->{r_currency2}}))};

        }
        foreach( keys %$ref_cash)
        {
        
                push @rate_cash,{from=>$ref_cash->{$_}->{r_currency1},to=>$ref_cash->{$_}->{r_currency2},rate=>to_prec6(pow($ref_cash->{$_}->{r_rate},$RATE_FORMS{$ref_cash->{$_}->{r_currency1}}->{$ref_cash->{$_}->{r_currency2}} ))};

        }
return (\@rate_cash,\@rate_cash_less);  
}
sub get_permit_accounts_simple
{
    my $oid=int(shift);
   
    my @rows=();
 
  
  my $str='';
    
   if($oid){
      $str=qq[ AND oaav_oid=$oid];
  }

   my $sql = qq[SELECT a_name,a_id,a_uah,a_usd,a_eur ,a_btc FROM accounts_view
    WHERE a_status='active' $str  ORDER BY lcase(a_name) 
   ];
   my $sth =$dbh->prepare($sql);
   $sth->execute();                          

   while(my $r = $sth->fetchrow_hashref)
   {
     $r->{title} ="$r->{a_name}(#$r->{a_id}) $r->{a_uah} UAH,$r->{a_usd} USD, $r->{a_eur} EUR, $r->{a_btc} BTC ";
     $r->{value} =$r->{a_id};	
     push @rows, $r;
   }

   $sth->finish();
   return       \@rows;


}
sub get_accounts_simple
{
    my $ac_id=shift;
    my $params=shift;
    $params={} unless($params);
   my @rows=();
   my $str;
   if($ac_id)
   {
    $str=" AND a_acid=$ac_id";
   }
   my $sql = qq[SELECT a_name,a_id,a_uah,a_usd,a_eur, a_btc FROM accounts  WHERE a_status='active' $str and a_id>0 ORDER BY lcase(a_name)
   ];
   my $sth =$dbh->prepare($sql);
   $sth->execute();                          

   while(my $r = $sth->fetchrow_hashref)
   {
     $r->{title} ="$r->{a_name}(#$r->{a_id}) $r->{$params->{currency}} ";
     $r->{value} =$r->{a_id};	
     push @rows, $r;
   }

   $sth->finish();
   return       \@rows;


}

sub get_accounts_simple_with_block
{
    my $ac_id=shift;
    my $params=shift;
    $params={} unless($params);
   my @rows=();
   my $str;
   if($ac_id)
   {
    $str=" AND a_acid=$ac_id";
   }
   my $sql = qq[SELECT a_name,a_status,a_id,a_uah,a_usd,a_eur, a_btc  FROM accounts  WHERE a_status!='deleted' $str ORDER BY lcase(a_name)
   ];
   my $sth =$dbh->prepare($sql);
   $sth->execute();                          

   while(my $r = $sth->fetchrow_hashref)
   {
     $r->{title} = "$r->{a_name}(#$r->{a_id}) $r->{$params->{currency}} ".(($r->{a_status} eq 'blocked')?'#':'');
     $r->{value} =$r->{a_id};	
     push @rows, $r;
   }

   $sth->finish();
   return       \@rows;


}


sub get_operators
{
	my $oid=shift;
	my @rows=();
	
	my $sql = qq[SELECT o_id,o_login,o_id as value,o_login as title  FROM operators WHERE o_status='active' AND o_type='in' ];
	my $sth =$dbh->prepare($sql);
	$sth->execute();
	push @rows,{o_login=>"Выберите оператора"};
 	while(my $r = $sth->fetchrow_hashref)
   	{
		 $r->{selected}=$oid==$r->{o_id};
		 push @rows, $r;
	}
 	$sth->finish();
   	return       \@rows;
}

sub get_accounts
{
   my @rows=();
   my $sql = qq[SELECT a_name,a_id,c_name as  a_class,a_uah,a_usd,a_eur,a_btc, c_id FROM accounts,classes
     WHERE a_status='active' AND c_id=a_class AND 1
     ORDER BY lcase(a_name)
   ];
   my $sth =$dbh->prepare($sql);
   $sth->execute();                          
   while(my $r = $sth->fetchrow_hashref)
   {
     $r->{title} = "$r->{a_name} (id#$r->{a_id}) [$r->{a_class}] $r->{a_uah} UAH   $r->{a_usd} USD, $r->{a_eur} EUR $r->{a_btc} BTC";
     push @rows, $r;
   }
   $sth->finish();
   return       \@rows;

}
sub paging
{
    my $params=shift;
    #{page,how,where,database object,url}
    $params->{page}=0 unless($params->{page});
    my $db=$params->{'database'};
    my $where=$params->{'where'};
    $params->{'page_name'}='page' unless($params->{'page_name'});
    my $sum;
   unless(defined($params->{'count_pages'}))
   {       
        $sum =$db->selectrow_array(qq[SELECT count(*) $where]);
   }else
   {
       $sum =$params->{'count_pages'};
       
   } 
    $params->{'how'}=500;
    my $from=$params->{page}*$params->{how};
    my $all=int($sum/$params->{'how'});
    $all+=1   if(int($sum%$params->{'how'}));

    my %current=($params->{page}=>'1');
    my @pages;

    for(my $i=0;$i<$all;$i++)
    {
        push @pages,{url=>$params->{url},urlparams=>'&how='.$params->{'how'} .'&'.$params->{'page_name'}.'='.$i,'val'=>$i,'page'=>$i+1,current=>$i==$params->{page}};
    }
#return pages ref to the array of pages where the hash key  page is index of page begining from 1 and 
#val from 0 ,flag current show the selected page url is the url of page

    return {pages=>\@pages,from=>$from,count_pages=>$all};
}


sub add2list{
  my ($ref_list, $add, $separator) = @_;
  $separator = ", " unless($separator);

  $$ref_list.=$separator if(length($$ref_list) > 0);
  $$ref_list.=$add;
}

sub set2hash{
  my $set = shift;
  my @arr = split(/\|/, $set);
  my %hash = ();
  foreach my $elem(@arr){
    next if( length("$elem") == 0 );
    $hash{$elem} = 1;
  }
  return \%hash;
}

sub now{
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  $year += 1900;
  $mon += 1;

  my $hash = {};
  $hash->{year} = $year;
  $hash->{mon} = $mon;
  $hash->{day} = $mday;
  $hash->{hour} = $hour;
  $hash->{min} = $min;
  $hash->{sec} = $sec;
  $hash->{sql} = "$year-$mon-$mday $hour:$min:$sec";

  return $hash;
}


sub month_last_day{
  my $year = shift;
  my $month = shift;

  my $y = $year-1900;
  my $m = $month-1;
  my $day = 32;

  my $time = 0;
  do{
    $day--;
    $time = mktime(0,0,12,$day,$m,$y); # +/- 1 hour

    #print localtime($time)."\n";
    my ($tsec, $tmin, $thour, $tday, $tmon, $tyear) = localtime($time);
    die if($tyear != $y); # bug, after 2038 or before 1970 !!!
    $time=undef if($tmon != $m);
  }while(!$time);

  $day="0$day"	if($day<10);
  return $day;
}


sub date_add{
  my $year  = shift;
  my $month = shift;
  my $day   = shift;
  my $add = shift;

  my $y = $year-1900;
  my $m = $month-1;
  
  my $time = mktime(0,0,12,$day,$m,$y); # +/- 1 hour
  $time += $add*60*60*24; #sec
  my ($tsec, $tmin, $thour, $tday, $tmon, $tyear) = localtime($time); # bug, after 2038 or before 1970 !!!
  $tyear+=1900;
  $tmon+=1;
  $tmon="0$tmon"	if($tmon<10);
  return {year=>$tyear, month=>$tmon, day=>$tday};
}








# sql = "$res->{start}<=ts AND $res->{end}>=ts"
sub time_filter{
  my $value = shift;

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  $year+=1900;
  $mon+=1;
  $wday=7 if($wday==0); #sunday=7
  
  my ($r1, $r2);

  $mon="0$mon"  if($mon<10);
  #if($value eq 'all_time'){
 #	$value ='this_month';
 # }


  if($value eq 'yesterday'){
    $r1 = date_add($year,$mon,$mday,-1);    
    $r2 = $r1;

  }elsif($value eq 'this_week'){
    $r1 = date_add($year,$mon,$mday,  1-$wday);
    $r2 = date_add($year,$mon,$mday,  7-$wday);

  }elsif($value eq 'prev_week'){
    $r1 = date_add($year,$mon,$mday, -6-$wday);
    $r2 = date_add($year,$mon,$mday,  0-$wday);

  }elsif($value eq 'this_month' || $value eq 'prev_month'){
    if($value eq 'prev_month'){
      $mon--;
      if($mon < 1){
        $mon=12;
        $year--;
      }
    }
	

    $r1 = {year=>$year, month=>$mon, day=>'01'};
    $r2 = {year=>$year, month=>$mon, day=>month_last_day($year,$mon)};

  }elsif($value eq 'this_year' || $value eq 'prev_year'){
    $year-- if($value eq 'prev_year');
    $r1 = {year=>$year, month=>'01', day=>'01'};
    $r2 = {year=>$year, month=>'12', day=>'31'};

  }elsif($value eq 'all_time'){
  #die "here";
    $r1 = {year=>'0000', month=>'00', day=>'00'};
    $r2 = {year=>'9999', month=>'12', day=>'31'};

  }elsif($value eq 'last_20')
  {
	return {
    	'start'=>$dbh->selectrow_array("select DATE_SUB(current_timestamp,interval 20 day)"),
    	'end'  =>$dbh->selectrow_array("SELECT DATE_ADD(current_timestamp,interval 1 day)"),
  	};
			

  }elsif($value eq 'prev_2month')
 {
	return {
    	'start'=>$dbh->selectrow_array("select DATE_SUB(current_timestamp,interval 2 month)"),
    	'end'  =>$dbh->selectrow_array("SELECT DATE_ADD(current_timestamp,interval 1 day)"),
  	};


 }elsif($value eq 'prev_3month')
 {
	return {
    	'start'=>$dbh->selectrow_array("select DATE_SUB(current_timestamp,interval 3 month)"),
    	'end'  =>$dbh->selectrow_array("SELECT DATE_ADD(current_timestamp,interval 1 day)"),
  	};


 }
else{ # today
    $r1 = {year=>$year, month=>$mon, day=>$mday};
    $r2 = $r1;
  }

  my $res={
    'start'=>"$r1->{year}-$r1->{month}-$r1->{day} 00:00:00",
    'end'  =>"$r2->{year}-$r2->{month}-$r2->{day} 23:59:59",
  };
  return $res;
}
sub document_list_uah_concl{
    my $ct_aid=shift;
    $ct_aid=string_mysql_clean($ct_aid);
    my ($parent_aid,$debt)=$dbh->selectrow_array(q[SELECT a_id,kand_debt FROM accounts LEFT JOIN kostial_accounts_new_docs ON kand_aid=a_id WHERE a_incom_id=?],undef,$ct_aid);
    unless($parent_aid){
            ###there is must be an error message
            return {};
    }
    my $percent=get_service_percent_client($ct_aid,$DOC_SERVICE);
   
      my @keys;
       my @res;
    my %main_hash=();
    my $min_date=$dbh->selectall_arrayref(qq[SELECT YEAR('$NEW_DOC_FROM_DATE'),
                                                    MONTH('$NEW_DOC_FROM_DATE'),
                                                    DAY('$NEW_DOC_FROM_DATE')]);



       


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
        
 
        my $sum=0;
        my $base_doc=0;
        my $fact_money=0;
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
             
                   
                }
                    
                $cur1=$i;
          }
          if($date eq $money_cash_without->[$cur3]->[0]){
                for($z=$cur3;$z<$size3&&$date eq $money_cash_without->[$z]->[0];$z++){
                $sum_transit+=$money_cash_without->[$z]->[3];###$money_transit->[$j]->[3] is mines sum

               
                }
                $fz=1;      
                $cur3=$z;


          }        


          if($date eq $money_transit->[$cur2]->[0]){
                
                for($j=$cur2;$j<$size1&&$date eq $money_transit->[$j]->[0];$j++){
                $sum_transit+=abs($money_transit->[$j]->[3]);###$money_transit->[$j]->[3] is mines sum
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

            
            if(defined($docs->{$date}->{'s'})&&$docs->{$date}->{'s'}!=0){
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
            $main_hash{$date}=\%hash;




    }


    return  \%main_hash;


}




sub  get_cash_conclusions
{
	 my ($self,$proto)=@_;
	
		my $ref=$dbh->selectrow_hashref(qq[SELECT * FROM accounts  WHERE a_id=$proto->{cash}]);
  		map {$proto->{$_}=format_float(-1*$ref->{$_})} keys %$ref;
		


   		my $type=$self->query->param('type_time_filter');
		my @filter_where;
 		if($type  eq 'time_filterinterval')
 		{
 			my $row1={};
 			my $from=$self->query->param('ct_date_from');
 			my $to=$self->query->param('ct_date_to');
 			push @filter_where,$from;
 			push @filter_where,$to;
 		}else
 		{
 			
			my $period=$self->query->param('ct_date');
 			
			my $res = time_filter($period);
# 			use Data::Dumper;
# 			die Dumper $res;
 			push @filter_where,$res->{start};
 			push @filter_where,$res->{end};
 		}
		
		my $status=q[('processed','returned')];
		
		

 		my $from=$dbh->selectrow_hashref(qq[
 		SELECT  
 		(
 			SELECT sum(ct_amnt) 
 			FROM  cashier_transactions 
 			WHERE  ct_fid=$proto->{cash}
			AND ct_status IN $status
 			AND  ct_currency='UAH' 
 			AND ct_ts2>=? GROUP BY ct_fid
		) AS UAH,
		(
			SELECT sum(ct_amnt) 
 			FROM  cashier_transactions 
 			WHERE  ct_fid=$proto->{cash}
			AND ct_status IN $status
 			AND ct_currency='USD' 
 			AND ct_ts2>=? GROUP BY ct_fid
		) AS USD,
		(
 			SELECT sum(ct_amnt) 
 			FROM  cashier_transactions 
 			WHERE  
			ct_fid=$proto->{cash}
			AND ct_status IN $status
 			 AND ct_currency='EUR' 
 			AND ct_ts2>=? GROUP BY ct_fid
		) as EUR
 		],undef,
  		$filter_where[0],

  		$filter_where[0],

  		$filter_where[0],
  	
		);
		
	

 		
 		my $to=$dbh->selectrow_hashref(qq[
 		SELECT
		(
			SELECT sum(ct_amnt) 
			FROM cashier_transactions 
			WHERE  ct_fid=$proto->{cash}
			AND ct_currency='UAH' 
			AND ct_status IN $status
			AND ct_ts2>=? AND ct_ts2<=? GROUP BY ct_fid
		) AS UAH, 
		( 
			SELECT sum(ct_amnt) 
			FROM cashier_transactions 
			WHERE  ct_fid=$proto->{cash} 
			AND ct_currency='USD' 
			AND ct_status IN $status
			AND ct_ts2>=? AND ct_ts2<=? GROUP BY ct_fid
		) AS USD,
		(
			SELECT sum(ct_amnt) 
			FROM cashier_transactions 
			WHERE  ct_fid=$proto->{cash} 
			AND ct_currency='EUR' 
			AND ct_status IN $status
			AND ct_ts2>=? AND ct_ts2<=? GROUP BY ct_fid
  		) AS EUR
 		],undef,
 		$filter_where[0],
 		$filter_where[1],
 		$filter_where[0],
 		$filter_where[1],
 		$filter_where[0],
 		$filter_where[1],
 		
 		);
		
		$proto->{f_name}='Фирма';


 		$proto->{beg_uah}=-1*($ref->{a_uah})-$from->{UAH};
		$proto->{beg_usd}=-1*($ref->{a_usd})-$from->{USD};
		$proto->{beg_eur}=-1*($ref->{a_eur})-$from->{EUR};
		
	
		my $non=$dbh->selectrow_hashref(
		qq[
		
		SELECT
		(SELECT sum(ct_amnt) FROM cashier_transactions WHERE ct_currency='UAH' AND ct_amnt<0 AND 
		ct_fid=$proto->{cash} AND 
		ct_status='created') as non_uah_mines,
		(
		SELECT sum(ct_amnt) FROM cashier_transactions WHERE  ct_currency='USD' AND ct_amnt<0 AND 
		ct_fid=$proto->{cash} AND 
		ct_status='created'
		) as non_usd_mines,	
		(SELECT sum(ct_amnt) FROM cashier_transactions WHERE ct_currency='EUR' AND ct_amnt<0 AND 
		ct_fid=$proto->{cash} AND ct_status='created') as non_eur_mines,
		(SELECT sum(ct_amnt) FROM cashier_transactions WHERE ct_currency='UAH' AND  ct_amnt>0 AND 
		ct_fid=$proto->{cash} AND 
		ct_status='created') as non_uah_plus,
		(SELECT sum(ct_amnt) FROM cashier_transactions WHERE  ct_currency='USD' AND ct_amnt>0 AND 
		ct_fid=$proto->{cash} AND 
		ct_status='created') as non_usd_plus,	
		(SELECT sum(ct_amnt) FROM cashier_transactions WHERE ct_currency='EUR' AND ct_amnt>0 AND 
		ct_fid=$proto->{cash} AND ct_status='created') as non_eur_plus		
		
		
		]);
				

		$proto->{non_uah_mines}=format_float($non->{non_uah_mines});
  		$proto->{non_usd_mines}=format_float($non->{non_usd_mines});
  		$proto->{non_eur_mines}=format_float($non->{non_eur_mines});
	
		$proto->{non_uah_plus}=format_float($non->{non_uah_plus});
  		$proto->{non_usd_plus}=format_float($non->{non_usd_plus});
  		$proto->{non_eur_plus}=format_float($non->{non_eur_plus});
	



		$proto->{orig__fin_uah}=$proto->{beg_uah}+$to->{UAH};
  		$proto->{orig__fin_usd}=$proto->{beg_usd}+$to->{USD};
  		$proto->{orig__fin_eur}=$proto->{beg_eur}+$to->{EUR};

 		$proto->{fin_uah}=format_float($proto->{orig__fin_uah});
  		$proto->{fin_usd}=format_float($proto->{orig__fin_usd});
  		$proto->{fin_eur}=format_float($proto->{orig__fin_eur});

		$proto->{orig__beg_uah}=$proto->{beg_uah};
  		$proto->{orig__beg_usd}=$proto->{beg_usd};
  		$proto->{orig__beg_eur}=$proto->{beg_eur};
	
		$proto->{beg_uah}=format_float($proto->{beg_uah});
  		$proto->{beg_usd}=format_float($proto->{beg_usd});
  		$proto->{beg_eur}=format_float($proto->{beg_eur});
		$proto->{from_date}=format_date($filter_where[0]);
 		$proto->{to_date}=format_date($filter_where[1]);

}

sub get_date_diff
{
	my ($date1,$date2)=@_;
	return $dbh->selectrow_array(qq[SELECT datediff('$date1','$date2')]);

}
sub get_date_sub
{
	my ($date,$days)=@_;
	return $dbh->selectrow_array(qq[SELECT date_sub('$date', interval $days day)]);


}
1;
