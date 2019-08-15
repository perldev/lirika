package SiteCommon;

use strict;

use SiteDB;	
use SiteConfig;
use base "Exporter";
use POSIX;

our @EXPORT = qw(
        $avail_currency @months
        &get_card_percent_serivce
        paging
        trim
        add2list
        set2hash
        get_rates
	get_exchanges
        $session_upgrade
        &get_accounts
        now
	&get_clients_accounts
    get_firm_services_percents_out_hash 
	&get_oper_accounts  
	&get_client_classes
	&get_classes
	&get_cash_trans_sum
	&get_firm_name
	&get_info_of_trans
	&handle_errors_add_trans
	&get_firm_information
	&get_account_name
	&get_cache_connection
	&get_service_name
	&send_mail
	&calculate_sum
	&sum_credit
	&last_record_credit
	
	&get_desc_rights
	&set_desc_rights

	&get_services_percents_client
	&get_services
	&get_services_percents
	&get_client_services_percents

	&get_firms

    @time_filter_rows
    &time_filter
    $chat_last_mesgs
    @currencies
	
	&get_out_firms_okpo
	&get_transit_list
	&get_trans_list
	&get_firm
 	&get_firm_services_percents_out
	&format_date
	&format_datetime
	&format_float
	&pow
	$predkassa_id
	$kassa_id
	$svoj_id
	$firms_id
	$exchange_id
	$credit_id
	$conv_currency
	$now_hash
	$FIRMS_TRANSACTIONS
	$avail_currency_firms
	&get_out_firms
	$FIRMS_CONV
	%MAIN_STATUSES
	$RESIDENT_CURRENCY
	
	&get_special_services
	$DELTA

	&normal_number

	&error_process
	&last_record
	
	get_oper_accounts
	get_oper_accounts_hash
	get_operators_firms
	get_normal_out_firms
	get_accounts_income
	add_transaction_document
    
    get_accounts_hash
    get_out_firms_hash
    get_firms_hash

	$OKPO_MIN
	$OKPO_MAX
	$SYSTEM_SERVICE
    get_doc_pecent
	my_decode
    get_years
    $DOCUMENTS_SERVICE
    format_datetime_month_year
    get_doc_info
    get_out_operators
    get_docs
    get_operators_firms_hash
);

our $session_upgrade=5;
our %MAIN_STATUSES=('created'=>'Создана',transit=>'Транзит','canceled'=>'Отменена','processed'=>'проведена');	
our $DOCUMENTS_SERVICE=55;
# special aid & fid
our $predkassa_id = -1;
our $kassa_id     = -2;
our $DELTA = -7;

our $svoj_id      = -3;
our $firms_id     = -4;
our $exchange_id  = -5;
our $credit_id    = -6;
our $FIRMS_TRANSACTIONS=-13;
our $RESIDENT_CURRENCY='UAH';
our $FIRMS_CONV=-2;
our $now_hash = now();
our $avail_currency={UAH=>'a_uah',USD=>'a_usd',EUR=>'a_eur'};
our $avail_currency_firms={UAH=>'f_uah',USD=>'f_usd',EUR=>'f_eur'};
our $conv_currency={UAH=>'ГРН',USD=>'USD',EUR=>'EUR'};
our $chat_last_mesgs=' 2 hour ';
our ($OKPO_MIN,$OKPO_MAX)=(8,10);
our $SYSTEM_SERVICE=65;
our @months=
        (
                {value=>1,name=>'Январь',title=>'Январь'},
                {value=>2,name=>'Февраль',title=>'Февраль'},
                {value=>3,name=>'Март',title=>'Март'},
                {value=>4,name=>'Апрель',title=>'Апрель'},
                {value=>5,name=>'Май',title=>'Май'}, 
                {value=>6,name=>'Июнь',title=>'Июнь'},
                {value=>7,name=>'Июль',title=>'Июль'},
                {value=>8,name=>'Август',title=>'Август'},
                {value=>9,name=>'Сентябрь',title=>'Сентябрь'},
                {value=>10,name=>'Октябрь',title=>'Октябрь'},
                {value=>11,name=>'Ноябрь',title=>'Ноябрь'},
                {value=>12,name=>'Декабрь',title=>'Декабрь'}
        );      
our %months=(
                '1'=>'Январь',
                '2'=>'Февраль',
                '3'=>'Март',
                '4'=>'Апрель',
                '5'=>'Май', 
                '6'=>'Июнь',
                '7'=>'Июль',
                '8'=>'Август',
                '9'=>'Сентябрь',
                '10'=>'Октябрь',
                '11'=>'Ноябрь',
                '12'=>'Декабрь',
                '01'=>'Январь',
                '02'=>'Февраль',
                '03'=>'Март',
                '04'=>'Апрель',
                '05'=>'Май', 
                '06'=>'Июнь',
                '07'=>'Июль',
                '08'=>'Август',
                '09'=>'Сентябрь',
                '10'=>'Октябрь',
                '11'=>'Ноябрь',
                '12'=>'Декабрь'
        );      

our @time_filter_rows=(
 {value=>"today",      title=>"Сегодня"},
 {value=>"yesterday",  title=>"Вчера"},
 {value=>"this_week",  title=>"Эта неделя"},
 {value=>"prev_week",  title=>"Пред. неделя"},
 {value=>"this_month", title=>"Это месяц"},
 {value=>"prev_month", title=>"Пред. месяц"},
 {value=>"this_year",  title=>"Этот год"},
 {value=>"prev_year",  title=>"Пред. год"},
);

our @currencies=(
	{'value'=>"", 'title'=>"Выбрать валюту"},
        {'value'=>"UAH", 'title'=>"ГРН"},
        {'value'=>"USD", 'title'=>"USD"},
        {'value'=>"EUR", 'title'=>"EUR"},
);
sub get_years{
    my $start_year=2007;
    my @years=();
    foreach(0..10){
        push @years,{title=>$start_year+$_,name=>$start_year+$_,value=>$start_year+$_};
    }
    return \@years

}

sub get_doc_info{
    my $id=shift;
    my $ref=$dbh->selectrow_arrayref(qq[SELECT dr_id,dr_amnt,dr_date,
                                               concat(of_name,'( ',of_okpo,' )') as of,
                                               a_name
                                        FROM documents_requests,out_firms,accounts
                                        WHERE 1
                                        AND dr_aid=a_id
                                        AND    dr_ofid_from=of_id
                                        AND dr_id=? 
                                       ],
                                        undef,$id);
    
    return $ref->[2]." ".$ref->[1]." ".$ref->[3]." ".$ref->[4] if($ref->[0]);
    return 'неизвестно'

}

sub get_docs{
    
    my $drids=shift;
    ###drids alwayes not empty  
    my $dr_str=join(',',@$drids);


    my $docs=$dbh->selectall_arrayref(qq[SELECT dr_id,
                                                dr_amnt,dr_date,
                                                concat(of_name,'( ',of_okpo,' )') as of,
                                                a_name
                                                FROM documents_requests,out_firms,accounts
                                                WHERE 1
                                                AND dr_aid=a_id
                                                AND    dr_ofid_from=of_id
                                                AND dr_id IN ($dr_str) 
                                       ]);
    my @result;
    foreach my $ref (@$docs){
            format_datetime_month_year(\$ref->[2]);
             push @result,{value=>$ref->[0],title=>$ref->[2]." ".$ref->[3]};


    }
    return \@result;
}
sub format_datetime_month_year
{
    my $str=shift;
    $$str=~/(\d{1,4})-(\d{1,2})-(\d{1,2})/;
    $$str=$months{$2}." $1 ";

}

sub my_decode
{
	my $r=shift;
	require Encode;
	Encode::from_to($r,'cp1251','utf8');
	utf8::decode($r);
	return $r;

}

sub get_accounts_hash
{
    my $sth=$dbh->selectall_hashref(qq[SELECT a_name as title ,a_id  
    FROM accounts WHERE a_status='active' AND a_acid=$CLIENT_CATEGORY ],'a_id');
    return $sth;
}
sub get_out_firms_hash
{
 my $sth=$dbh->selectall_hashref(qq[SELECT of_id,of_name as title  FROM out_firms  ],'of_id');
    return $sth;

}
sub get_firms_hash
{
    my $sth=$dbh->selectall_hashref(qq[SELECT f_id,f_name as title  FROM firms  ],'f_id');
    return $sth;


}


sub get_normal_out_firms
{
	my $sth=$dbh->prepare(q[SELECT of_id,LOWER(of_name) as of_name,of_okpo FROM out_firms]);
	$sth->execute();

	my @ref;
	while(my $r=$sth->fetchrow_hashref())
	{
		
	       $r->{of_name}=~s/[\']/\\'/g;        
		   push @ref,{ title=> $r->{of_name},value=>$r->{of_id},of_okpo=>$r->{of_okpo} };

	}
	$sth->finish();

	return \@ref;


}
sub get_firm_services_percents_out
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
        fs_status='active' AND fs_id IN($slist)  AND fs_type='out' AND fs_id>0 ]); 
    my @res;
    map {push @res,{fs_name=>$_->[0],fs_id=>$_->[1],percent=>$_->[2]}} @$ref;
    return \@res;
    
}
sub get_firm_services_percents_out_hash
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
    
    return $dbh->selectall_hashref(qq[SELECT fs_name,fs_id FROM firm_services 
        WHERE  
        fs_status='active' AND fs_id IN($slist)  AND fs_type='out' AND fs_id>0 ],'fs_id'); 

  
    
}
sub get_out_firms_okpo
{
        my $sql = qq[
	         SELECT * FROM out_firms WHERE of_okpo IS NOT NULL
		          ORDER BY binary lcase(of_name)
			         ];
 
        my @titles=();
        my $sth =$dbh->prepare($sql);
        $sth->execute();                          
	    while(my $r = $sth->fetchrow_hashref)
	    {
	          push @titles, {"value"=>$r->{of_id}, "title"=>"$r->{of_okpo}"};
	    }
	     $sth->finish();
	     return \@titles;
}

sub get_doc_pecent{

    my ($aid,$date)=@_;
    my $percent=$dbh->selectrow_array(qq[SELECT cs_percent FROM accounts,
                    client_services
                    WHERE a_id=? AND cs_aid=a_id AND  cs_month=MONTH('$date') AND 
                    cs_year=YEAR('$date') AND  cs_fsid=? ],undef,$aid,$DOCUMENTS_SERVICE);
     if($percent){
        return $percent;

    }


    $percent=$dbh->selectrow_array(qq[SELECT cs_percent FROM accounts,
                    client_services
                    WHERE a_id=? AND cs_aid=a_id AND  cs_month<=MONTH('$date') AND 
                    cs_year<=YEAR('$date') AND  cs_fsid=? ORDER BY cs_ts  LIMIT 1],undef,$aid,$DOCUMENTS_SERVICE);
 
    return 1.2 unless($percent);###for very old records
    return $percent;
}									     
sub add_transaction_document
{
		my $q=shift;
	
		my %q=%$q;
		
		
		
		$q{dt_amnt}=~s/[,]/\./g;
		$q{dt_amnt}=~s/[ ]//g;

		die "Неправильный формат суммы \n" unless($q{dt_amnt}*1);

		$q{dt_aid}=0 if($q{dt_aid}!=0&&!$dbh->selectrow_array(q[SELECT 
		a_id FROM accounts WHERE a_id=?],undef,$q{dt_aid}));

	        my $sql = qq[SELECT * FROM firms_out_operators
			WHERE 
			f_status='active' AND f_id=? AND o_id=?
			ORDER BY f_name 
			];
       	 	my $sth =$dbh->selectrow_hashref($sql,undef,$q{dt_fid},$q{user_id});
		
		die "У вас нет такой фирмы \n" unless($sth->{f_id});
		
		$q{dt_comment}='приходные документы';

		$q{'dt_infl'}='no';

		$q{'dt_status'}='created';


       my ($of_id,$okpo)=(0,0);

       unless($q{dt_ofid}*1){
       
            $okpo=$q{dt_ofid};
            $okpo=~/[^\d]+(\d+)[^\d]*$/;
            $okpo=$1;
            die "У фирмы покупателя не обнаружен  код ОКПО ! \n"    unless($okpo);

            die "Код ОКПО должен быть 8-10 значным числом! \n"    if(length($okpo)>$OKPO_MAX || length($okpo)<$OKPO_MIN);
		   my %tmp_okpo;
		   my @tmp_okpo_arr = split(//,$okpo);
		   
		   foreach my $var(@tmp_okpo_arr)
		   {
		   	   $tmp_okpo{$var}++;
		   }
       	   die "Код ОКПО должен содердать хотя бы 3 разных цифры" if(scalar keys %tmp_okpo<3);


           ($of_id,$okpo)=$dbh->selectrow_array(q[SELECT of_id,of_okpo FROM out_firms 
            WHERE  of_okpo=?],undef,$okpo);
	    
        }else{
		    ($of_id,$okpo)=$dbh->selectrow_array(q[SELECT of_id,of_okpo FROM out_firms 
		    WHERE of_id=?],undef,$q{dt_ofid}*1);
        }
	
        unless($of_id){
            $okpo=$q{'dt_ofid'};
            $q{'dt_ofid'}=~/(\d+)[^\d]*$/;
            $okpo=$1;    
            $dbh->do(q[INSERT INTO out_firms(of_name,of_okpo) VALUES(?,?)],undef,$q{'dt_ofid'},$okpo);
            $q{'dt_ofid'}=$dbh->selectrow_array(q[SELECT last_insert_id() ]);
        }else{
	
	    $q{dt_ofid}=$of_id;
	    
	}


            

	
		if($q{dt_aid})
		{
			my ($id,$sum)=$dbh->selectrow_array(q[SELECT 
				dr_id,dr_amnt 
				FROM documents_requests 
				WHERE 
				dr_status='created' 
				AND dr_fid=? 
				AND MONTH(dr_date)=MONTH(?)    
                AND YEAR(dr_date)=YEAR(?)
				AND dr_ofid_from=? 
				AND dr_aid=?
				AND dr_currency=? 
			],undef,$q{dt_fid},$q{dt_date},$q{dt_date},$q{dt_ofid},$q{dt_aid},'UAH');
			
			my $percent;
			$percent=get_doc_pecent($q{dt_aid},$q{dt_date}) if ($q{dt_aid});

			$percent=1.2 if($percent<=0);

			unless($id)
			{
				$dbh->do(qq[INSERT INTO documents_requests
				(dr_comis,dr_aid,dr_amnt,dr_comment,dr_fid,dr_ofid_from,dr_oid,dr_date)
				VALUES($percent,?,?,?,?,?,?,?)
				],
				undef,$q{dt_aid},$q{dt_amnt},
				$q{dt_comment},$q{dt_fid},$q{dt_ofid},$q{user_id},$q{dt_date});
				my $doc_id=$dbh->selectrow_array(q[SELECT last_insert_id()]);
			
				$dbh->do(qq[INSERT INTO documents_payments(dp_ctid,dp_drid,dp_tid) VALUES(?,?,?)],undef,0,$doc_id,0);
				
				$dbh->do(
				qq[INSERT INTO documents_requests_logs
				(dr_comis,dr_aid,dr_amnt,dr_comment,dr_fid,dr_ofid_from,dr_oid,dr_date)
				VALUES($percent,?,?,?,?,?,?,?)
				],undef,$q{dt_aid},$q{dt_amnt},$q{dt_comment},$q{dt_fid},$q{dt_ofid},$q{user_id},$q{dt_date});
				$q{dt_drid}=$doc_id;
				$q{'dt_infl'}='yes';


			
			}else
			{
	
				my $sum_fact=$dbh->selectrow_array(q[SELECT sum(dt_amnt) 
				FROM 
				documents_transactions 
				WHERE dt_drid=?  
				AND (dt_status='created' 
				OR  dt_status='processed')
				GROUP BY dt_drid],undef,$id);
			
								
				$sum_fact+=$q{dt_amnt};

				
				
				my $payd_sum=$dbh->selectrow_array(q[SELECT  dr_amnt*(sum(t_amnt)/(dr_comis*(dr_amnt/100))) as payd_sum 
								     FROM 
								     documents_payments,transactions,documents_requests
								     WHERE dp_tid=t_id 
								  AND dr_id=dp_drid AND dr_id=? GROUP BY dr_id],undef,$id);

				$q{'dt_status'}='processed' if($payd_sum>=$sum_fact);
				if($sum_fact>$sum)
				{
					$dbh->do(q[UPDATE documents_requests SET dr_amnt=?  WHERE dr_id=?],undef,$sum_fact,$id);
					$q{'dt_infl'}='yes';

				}
				$q{'dt_drid'}=$id;
			
			}
			
		}
	
		$dbh->do(q[INSERT INTO
		 documents_transactions(dt_amnt,dt_aid,dt_fid,dt_comment,dt_oid,dt_ts,dt_status,dt_ofid,
		dt_date,dt_drid,dt_infl) 
		VALUES(?,?,?,?,?,current_timestamp,?,?,?,?,?)],undef,
		$q{dt_amnt},$q{dt_aid},$q{dt_fid},$q{dt_comment},$q{user_id},$q{'dt_status'},$q{dt_ofid},
		$q{dt_date},$q{dt_drid},$q{dt_infl}
		);

	return $dbh->selectrow_array(q[SELECT last_insert_id()]);	
	
}
sub get_accounts_income
{

	my $sth=$dbh->prepare(q[SELECT LOWER(a_name) as a_name,a_incom_id FROM accounts WHERE a_status ='active' 
	AND a_incom_id IS NOT NULL ]);
	$sth->execute();
	my @ref;
	while(my $r=$sth->fetchrow_hashref())
	{
		$r->{a_name}=~s/[\']/\\'/g;
		$r->{a_name}=~s/[ ]//g;
		
		push @ref,{ title=>$r->{a_name},value=>$r->{a_incom_id} };
	}
	
	$sth->finish();
	
	return \@ref;
}


sub get_oper_accounts
{
	my $o_id=shift;
	
	my $sth=$dbh->prepare(q[SELECT * FROM clients_out_operators WHERE o_id=?]);
	my @res=();
	$sth->execute($o_id);
	while(my $r=$sth->fetchrow_hashref())
	{
		push @res,$r;
	
	}
	$sth->finish();
	
	return \@res;

}
sub get_out_firms
{
	
	   my $sql = qq[
      	 SELECT * FROM out_firms
      	 ORDER BY of_name
       ];
   
       my @titles=();
       my $sth =$dbh->prepare($sql);
       $sth->execute();                          
       while(my $r = $sth->fetchrow_hashref)
       {
    		 #$r->{of_name}=~s/[\']/\\'/g;
	        push @titles, {"value"=>$r->{of_id}, "title"=>"$r->{of_name} (id#$r->{of_id})"};
       }
	unshift @titles,{title=>'Все'};
       $sth->finish();
       return \@titles;
	
	
}
sub get_oper_accounts_hash
{
	my $o_id=shift;
	return $dbh->selectall_hashref(qq[SELECT * FROM clients_out_operators WHERE o_id=$o_id],'a_id');
	

}
#for calculating accounts_reports
##and using in the reports
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

sub get_out_operators
{
	my $oid=shift;
	my @rows=();
	
	my $sql = qq[SELECT o_id,o_login,o_id as value,o_login as title  
		    FROM operators WHERE o_status='active' AND o_type='out' ];
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

#get_clients_accounts  
#get_oper_accounts
sub get_operators_firms_hash{
    my $user_id=shift;
    my $ref=$dbh->selectall_hashref(qq[SELECT f_id,f_name FROM operators_firms,firms WHERE  of_oid=$user_id 
    AND of_fid=f_id ],'f_id');
    return  $ref;

}

sub get_operators_firms
{
    my $user_id=shift;
	
	my $sth=$dbh->prepare(q[SELECT f_name,f_id FROM operators_firms,firms WHERE  of_oid=? 
	AND of_fid=f_id ]);
	
	my @res=();
	$sth->execute($user_id);
	while(my $r=$sth->fetchrow_hashref())
	{
		push @res,{value=>$r->{f_id},title=>"$r->{f_name}(#$r->{f_id})"};
	
	}
	$sth->finish();
	return \@res;

	
    
    
}  

sub get_clients_accounts
{

    my $sth=$dbh->prepare(q[SELECT a_name as title ,a_id as value FROM accounts WHERE a_status='active' AND a_acid=? ORDER BY a_name]);
	my @res=();
	    $sth->execute($CLIENT_CATEGORY);
		while(my $r=$sth->fetchrow_hashref())
		    {
			    push @res,$r;
				
				}
			unshift @res,{title=>'Все'};
				    return \@res;
				    
}
				    
				    

sub format_date
{
	my $str=shift;
	$str=~/(\d{1,4})-(\d{1,2})-(\d{1,2})/;
	return "$3.$2.$1";
}
sub format_datetime
{
	my $str=shift;
	$str=~/(\d{1,4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/;
	return "$3.$2.$1";
}
sub get_firm_name
{
    my $id=shift;
	my $sql = qq[SELECT * FROM firms
	       WHERE f_status='active' AND f_id=?
	              ];
		        my $r=$dbh->selectrow_hashref($sql,undef,$id);
			        
			    return {f_percent=>$r->{f_percent},firm_id=>$r->{f_id},firm_title=>"$r->{f_name} (id#$r->{f_id})",ext_info=>
				"$r->{f_name} (id#$r->{f_id}) ".format_float($r->{f_uah}).' UAH, '.format_float($r->{f_usd}).' USD,'
				    .format_float($r->{f_eur}).' EUR',
					f_uah=>$r->{f_uah},
					    f_usd=>$r->{f_usd},
						f_eur=>$r->{f_eur},
						    };
						    
						    
						    }
sub format_float
{
	my $f=shift;
	return 0 if(abs($f)<0.0001);
#	$f=~s/,/\./g;
#	die $f;
	$f=ceil($f*100)/100;
	$f=~/^([\-])?(\d+)\.(\d+)$|([\-])?(\d+)/;
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
sub normal_number
{
	my $num=shift;
	
	$num=~s/[ ,]//g;
	
	return $num*1;

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

sub trim {
    @_ = @_ ? @_ : $_ if defined wantarray;
    
    for (@_ ? @_ : $_) { s/\A\s+//; s/\s+\z// }

    return wantarray ? @_ : "@_";
}




sub get_special_services
{
	my @arr=@_;
	my $str=join(',',@arr);
	

	my $ref=$dbh->selectall_arrayref(qq[SELECT fs_name,fs_id FROM firm_services 
		WHERE  
		fs_status='active' AND fs_id IN($str) AND fs_id>0 ]);	
	my @res;
	push @res,{fs_name=>'Выбрать услугу',fs_id=>''};
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
sub get_services
{
	my $hash=$dbh->selectall_hashref(q[SELECT fs_id,fs_name FROM firm_services WHERE fs_status='active' AND fs_id>0],'fs_id');
	my @arr;
	map {push @arr,$hash->{$_}} keys %$hash;
	return \@arr;
}

sub get_classes
{
	  my $ref_cash=$dbh->selectall_arrayref("SELECT 1,c_id,c_name,c_ts FROM classes WHERE 1 ORDER BY c_name");
	  my @arr;
	  map{ push @arr,{value=>$_->[2],title=>$_->[2],c_status=>$_->[0],c_id=>$_->[1],c_name=>$_->[2],c_ts=>$_->[3]} } @$ref_cash;
	  return \@arr;
}
sub get_client_services_percents
{
	     	#push @titles, {	
	#	"value"=>$r->{fs_id}, 
         #        "title"=>"$r->{fs_name} (id#$r->{fs_id}) "#$title"
          #     	};
	#	map {push @{$proto->{fields}},{no_base=>1,'system'=>1,'no_view'=>1,field=>$r->{fs_id}."_".$_->{a_id},value=>$_->{cs_percent}} }  @$ref;

	my $fs_id=shift;
	
	my $ref=$dbh->selectall_arrayref(q[SELECT fs_id,cs_aid as a_id,cs_percent 
					  FROM client_services,firm_services WHERE 
					  cs_fsid=fs_id AND fs_status='active' AND fs_id=?],undef,$fs_id);

	my @res;
	
	map {push @res,{fs_id=>$_->[0],a_id=>$_->[1],cs_percent=>$_->[2]} } @$ref;
	
	return \@res;
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


sub get_accounts_simple
{
   my @rows=();
   my $sql = qq[SELECT a_name,a_id FROM accounts ORDER BY lcase(a_name)
   ];
   my $sth =$dbh->prepare($sql);
   $sth->execute();                          

   while(my $r = $sth->fetchrow_hashref)
   {
     $r->{title} ="$r->{a_name}(#$r->{a_id})";
     $r->{value} =$r->{a_id};	
     push @rows, $r;
   }

   $sth->finish();
   return       \@rows;


}
sub get_accounts
{
   my @rows=();
   my $sql = qq[SELECT a_name,a_id,c_name as  a_class,a_uah,a_usd,a_eur,c_id FROM accounts,classes
     WHERE a_status='active' AND c_id=a_class AND 1
     ORDER BY lcase(a_name)
   ];
   my $sth =$dbh->prepare($sql);
   $sth->execute();                          
   while(my $r = $sth->fetchrow_hashref)
   {
     $r->{title} = "$r->{a_name} (id#$r->{a_id}) [$r->{a_class}] $r->{a_uah} UAH, $r->{a_usd} USD, $r->{a_eur} EUR";
     push @rows, $r;
   }
   $sth->finish();
   return       \@rows;

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
    $r1 = {year=>'0000', month=>'00', day=>'00'};
    $r2 = {year=>'9999', month=>'12', day=>'31'};

  }else{ # today
    $r1 = {year=>$year, month=>$mon, day=>$mday};
    $r2 = $r1;
  }

  my $res={
    'start'=>"$r1->{year}-$r1->{month}-$r1->{day} 00:00:00",
    'end'  =>"$r2->{year}-$r2->{month}-$r2->{day} 23:59:59",
  };
  return $res;
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
