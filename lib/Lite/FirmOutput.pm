package Lite::FirmOutput;
use strict;
use base 'CGIBaseLite';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $firm_services = undef;
# 
# java_script_action
# java_script
my $proto={
  'table'=>"cashier_transactions",  
  'template_prefix'=>"firm_out",
  'extra_where'=>"ct_amnt < 0 AND ct_fid>0 AND ct_status!='deleted'",
  'page_title'=>'Отправка безнала',
  'need_confirmation'=>1,
  'id_field'=>'ct_id',
  'sort'=>' ct_date DESC',
  'init_java_script'=>q[
		


		var services_percents=new Array();
		var start_;
		function getReq()
		{
			var ready=REQ.readyState;
			var data=null;
			if(ready==READY_STATE_COMPLETE)
			{
				data=REQ.responseText;
				fill_array(data);
				//very important thing there 
				change_services();
				start_=0;
			}
		
		}
		function SendRequest(url,params,HttpMethod)
		    {
			    if(!HttpMethod)
				    HttpMethod='POST';
			    
			    REQ=getHttp();
			    if(REQ)
			    {
				    REQ.onreadystatechange=getReq;
				    REQ.open(HttpMethod,url,true);
				    REQ.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
				    REQ.send(params);
			    }
			    
	    
			    
			    
		    }
		function fill_array(data)
		{
				//read xml		
		
				if (window.ActiveXObject)
  				{
  					var doc=new ActiveXObject("Microsoft.XMLDOM");
					doc.async="false";
  					doc.loadXML(data);
  				}// code for Mozilla, Firefox, Opera, etc.
				else
  				{
  					var parser=new DOMParser();	
  					var doc=parser.parseFromString(data,"text/xml");
  				}
				
				
				var x=doc.documentElement;
				var users=x.getElementsByTagName("user");
				var services=x.getElementsByTagName("service");
				var percents=x.getElementsByTagName("percent");
				for(var i=0;i<users.length;i++)
				{
					
					var tmp=new Array();
					tmp[0]=users[i].childNodes[0].nodeValue*1;
					tmp[1]=services[i].childNodes[0].nodeValue*1;
					if(percents[i].childNodes[0]&&percents[i].childNodes[0].nodeValue)
								tmp[2]=percents[i].childNodes[0].nodeValue*1;
					
					services_percents.push(tmp);
					
				}
				
				
				//	
				
			
			
		}
		
	
		function search_if_exist(id,service)	
		{
				if(!id||!service)
					return;
				id=id*1;
				service=service*1;
				for(var i=0;i<services_percents.length;i++)
				{
					
					if(1*services_percents[i][0]==id&&1*services_percents[i][1]==service)
					{	
						return services_percents[i][2]*1;
					}
		
				}
			
			return null; 
		}
		function change_services()
		{
		
			var  id_val;
			if(document.getElementById('ct_aid__select'))
			{
				id_val=document.getElementById('ct_aid__select').value;
				document.getElementById('ct_aid').value=id_val;
			}
			else if(document.getElementById('ct_aid').value)
				id_val=document.getElementById('ct_aid').value;


			var selected_service=document.getElementById('ct_fsid').value;
			if(!document.getElementById('ct_aid')||
			!document.getElementById('ct_aid').value)
			{
					set_element('ct_comis_percent',0);
					set_element('common_sum',0);
					return;
		
			}else if(!selected_service)
			{
				change_comission();
				return;
			}

		
			var user_status;
			var val=search_if_exist(id_val,selected_service);
			if(!val&&val!=0)
			{
				start_=1;
				SendRequest("ajax.cgi","do=get_account_services_percent&service="+selected_service,null);
				
				
				
			}else
			{	
					change_comission(val);
				
			}
	}		
	function change_comission(percent)
	{
					


					if(percent)
					{
					set_element('ct_comis_percent',percent);
					
					}
					var amnt;
					amnt=get_element('ct_amnt');
					var ext_com;
					ext_com=get_element('ct_ext_commission',1);
					var val;
					val=get_element("ct_comis_percent",1);
					amnt1=(amnt*val)/100;
					amnt1=Math.ceil(amnt1*100)/100;
					set_element('commission',amnt1);
					amnt=1*amnt+amnt1*1+ext_com*1;
				   	set_element('common_sum',Math.ceil(amnt*100)/100);

		
	}
//	change_services();

	],

  'fields'=>[
    {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1,filter=>'=','filter_invisible'=>'1'},    
    {'field'=>"ct_date","no_add_edit"=>1, "no_view"=>1, "title"=>"Дата", 'filter'=>"time"},
    {'field'=>"ct_ts","no_add_edit"=>1, "no_view"=>1, "title"=>"Дата изм", },
    {'field'=>"ct_tid2_ext_com","no_add_edit"=>1, "no_view"=>1},

  
    {'field'=>"ct_fid", "title"=>"Фирма", "category"=>"firms", 'filter'=>"="
     , "type"=>"select","no_add_edit"=>1,
    },    
    {'field'=>"ct_aid", "title"=>"Карточка", "category"=>"accounts"},
    {'field'=>"ct_fsid", "title"=>"Услуга","category"=>"firm_services", "type"=>"select", "may_null"=>1,
     java_script_action=>'onchange="change_services()"',
      "titles"=>$firm_services},
   {'field'=>"ct_currency", "title"=>"Валюта", 'filter'=>"=",
     "no_add_edit"=>1,
      'filter'=>"=", "type"=>"select", "titles"=>\@currencies	     
    },
    {'field'=>"ct_status", "title"=>"Статус проведения"
     , "type"=>"select"
     , "titles"=>[
        {'value'=>"created", 'title'=>"в процессе"},
        {'value'=>"processed", 'title'=>"проведен"},
     ]
     , 'filter'=>"="
     , "no_add_edit"=>1,
     , "no_view"=>1,
    },
    {
	'field'=>"ct_amnt", "title"=>"Сумма", 'filter'=>"=", 'op'=>'-', "positive"=>1
    	
    },
{'field'=>"ct_comis_percent","title"=>"Комиссия%",'default'=>"0",
	java_script_action=>'onkeyup="change_comission()"',etalon=>$ETALON_VALUE_COMIS},
 


    {'field'=>"commission", "title"=>"Комиссия ",'default'=>"0",'system'=>1,"no_add_edit"=>1,no_base=>1},
    {'field'=>"common_sum", "title"=>"Общая сумма",'default'=>"0",'system'=>1,"no_add_edit"=>1,no_base=>1},
    {'field'=>"ct_eid",'title'=>'Произвести обмен','system'=>1,"category"=>"exchange",'value'=>'ct'},	

	 {'field'=>"ct_comment","title"=>"Назначение", 'default'=>"Вывод безнала",'filter'=>'like'},
    
    {'field'=>"ct_ts2","title"=>"Дата занесения", category=>'date'},
        {
    'field'=>"ct_ext_commission","title"=>"Дополнительная комиссия",
     'default'=>"0",java_script_action=>'onkeyup="change_comission()"'
    },

    {'field'=>"ct_oid", "title"=>"Оператор"
      , "no_add_edit"=>1, "category"=>"operators"
    },
   {'field'=>"ct_oid2", "title"=>"Оператор проведения"
      , "no_add_edit"=>1, "category"=>"operators",no_view=>1
    },
    #{'field'=>"ct_tid", "title"=>"Транзакция", "no_add_edit"=>1,},


    {'field'=>"ct_status", "title"=>"Статус проведения"
     , "no_add_edit"=>1
     , "no_view"=>1
    },


    {'field'=>"ct_tid2", "title"=>"Транзакция 2"
      , "no_add_edit"=>1
      ,"no_view"=>1
    },
    {
	
	'field'=>"ct_tid2_comis", "title"=>"Транзакция 2, комиссия"
      , "no_add_edit"=>1
      ,"no_view"=>1
    },



  ],
};

sub setup
{
  my $self = shift;

  $self->run_modes(
    	'edit' => 'edit',
     	'add_many'=>'add_many',
    	'add_common_confirm'=>'add_common_confirm',
    	'add_common_do'=>'add_common_do'
  );
}
sub get_right
{       
        my $self=shift;
        return 'firm_out';
}
sub edit
{
	my $self = shift;
	foreach(@{$proto->{fields}})
	{
			if($_->{field} eq 'ct_amnt')
			{
				$_->{'no_add_edit'}=1;
				$_->{'positive'}=undef;
			}
	}
	my $action=$self->query->param('action');
	my $param=$self->query->param('__confirm');
	my %params;
	map{ $params{$_}=$self->query->param($_) }  $self->query->param();
	delete $params{'apply'};
	delete $params{'do'};
	delete $params{'__confirm'};
	$params{'do'}='edit';
	
  	if($action eq 'apply'&&!$param)
  	{
		
		my $ref=get_info_of_trans($params{id});
		$params{ct_amnt}=abs($ref->{ct_amnt});
		my $firm_=get_firm_name($ref->{ct_fid});
	
		my $account_=get_account_name($params{ct_aid});
		my $service_=get_service_name($params{ct_fsid});	
		my $percent=$params{ct_comis_percent};
		$self->{tpl_vars}->{ct_comis_percent_exchange}=$params{ct_comis_percent_exchange};

		$params{ct_id}=$params{id};

		$self->{tpl_vars}->{ct_currency}=$conv_currency->{$ref->{ct_currency}};

		$self->{tpl_vars}->{ct_ts2}=$params{ct_ts2};
		$self->{tpl_vars}->{ct_ts2_unformat}=format_date($params{ct_ts2});


		$self->{tpl_vars}->{page_title}="Подтверждение формы";
		
		$self->{tpl_vars}->{firm_info}=$firm_->{ext_info};
		$self->{tpl_vars}->{account_info}=$account_->{ext_info};
		$self->{tpl_vars}->{service_info}=$service_->{service_title};
		$self->{tpl_vars}->{commission}=($params{ct_amnt}/100)*$percent;

		
		$self->{tpl_vars}->{common_sum}=$self->{tpl_vars}->{commission}+$params{ct_amnt}+$params{ct_ext_commission};	
		
		$self->{tpl_vars}->{rate}=$params{rate};
		$self->{tpl_vars}->{currency}=$params{currency};
		$self->{tpl_vars}->{exchange_yes}=$params{exchange_yes};
		my $t;
		($self->{tpl_vars}->{exchange_sum},$params{rate_})=$self->calculate_exchange
		(
		$self->{tpl_vars}->{common_sum},
		$params{rate},
		$ref->{ct_currency},$params{currency}
		);


		map {$self->{tpl_vars}->{$_}=$params{$_}} keys %params; 
		
		my $tmpl=$self->load_tmpl('firm_output_confirm.html');
		my $output='';
		$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
		return $output;

	}elsif($action eq 'apply'&&$param)
	{
		$params{update}=1;
		
		my $exchange_yes=$self->query->param('exchange_yes');
		my $ct_aid=$self->query->param('ct_aid');
		my $light_rate=$self->query->param('rate');
		my $source_currency=$self->query->param('currency');
		$ct_aid=$dbh->selectrow_array('SELECT a_id FROM accounts WHERE a_id=?',undef,$ct_aid);
		return error_process $self,"Вы не выбрали карточку \n " unless($ct_aid);
		if($exchange_yes)
		{
					
					
			return error_process $self, "Не задан курс обмена \n"	unless($light_rate);
			return error_process $self, "Не задана валюта обмена \n" unless($avail_currency->{$source_currency});
			

 			my $currencies=$dbh->selectrow_array(q[SELECT 
 			ct_currency FROM cashier_transactions 
 			WHERE ct_id=?],undef,$params{id});
 			return error_process $self, "Выберите разные валюты \n" if($source_currency eq 
 			$currencies);

 
					
		}


		return $self->proto_add_edit_trigger(\%params);	
	
	}

	
  return $self->proto_add_edit('edit', $proto);

}


sub proto_add_edit_trigger{
  	
	my $self=shift;
  	my $params = shift;
	  $proto->{params}={};
	  $proto->{params}->{ct_ts2}=$self->query->param('ct_ts2');
	  $proto->{params}->{ct_comment}=$self->query->param('ct_comment');

       'step'=>'before',    
   	my $tid = 'NULL';
   	my $tid_comis = 'NULL';
   	my $ext_com_id='NULL';
   	my $eid='NULL';
    my $id = $self->query->param('id');

	require POSIX;
	my $ra  = $dbh->selectrow_hashref("SELECT * FROM accounts WHERE a_id = ".sql_val( $params->{ct_aid} ));
    $proto->{params}->{a_name}=$ra->{a_name};
    $proto->{params}->{a_id}=$ra->{a_id};
    $proto->{params}->{id}=$id;

	return error_process $self,"Выберите разные валюты \n" if(defined $params->{exchange_yes}&&$params->{currency} eq 
	$params->{ct_currency});	

	###protection from twice runs
	my $protection=$dbh->do(q[UPDATE cashier_transactions 
			   	 SET ct_status='processing',ct_aid=?
   		      	         WHERE ct_id=? AND ct_status='created' 
			 ],undef,$params->{ct_aid},$params->{ct_id}); 
	
	if($protection ne '1')
	{
	
		return $self->ok($params);
	}




		($params->{ct_fid},$params->{ct_currency},$params->{ct_ts},
		$params->{ct_currency},$params->{ct_amnt},$params->{ct_comment_},$params->{ct_req})=$dbh->selectrow_array(q[SELECT ct_fid,ct_currency,
			current_timestamp,
			ct_currency,
			abs(ct_amnt),
			ct_comment,
			ct_req
			FROM cashier_transactions 
			WHERE 
			ct_id=? AND 
			ct_status='processing'],undef,$params->{ct_id});
	
       my $rfs;     
	$params->{ct_comment}=$params->{ct_comment_}   unless($params->{ct_comment});

 
      $rfs = $dbh->selectrow_hashref("SELECT * FROM firm_services,client_services WHERE cs_aid=? AND
      cs_fsid=fs_id AND cs_fsid=".sql_val( $params->{ct_fsid} ),undef,$params->{ct_aid}) if($params->{ct_fsid});

     my $rf = $dbh->selectrow_hashref("SELECT * FROM firms 
					 WHERE f_id = ".sql_val( $params->{ct_fid} ));
     my $per=abs($params->{ct_comis_percent});
     my $service_title='';
     
	if($per>0)	
     	{
		$service_title=" $per\% за услугу $rfs->{fs_name} (id#$rfs->{fs_id})";
     	}
	
     if(defined $params->{exchange_yes}&&0)
     {	
			
		my $amnt;
		my $rate=$params->{rate};
		($amnt,$rate)=$self->calculate_exchange(0,$rate,$params->{currency},$params->{ct_currency});

		$amnt=abs(($params->{ct_amnt}/100)*$per);
		$amnt=$amnt+$params->{ct_amnt}+$params->{ct_ext_commission};
		$amnt=$amnt/$rate;
			
		$eid=$self->add_exc(
		{
			e_date=>$params->{ct_ts},
			a_id=>$params->{ct_aid},
			e_currency1=>$params->{currency},
			e_currency2=>$params->{ct_currency},
			rate=>$params->{rate},
			type=>'auto',
			e_amnt1=>$amnt,
			e_comment=>'Автообмен при индентификации прихода по курсу '.$params->{rate}
      		});

	
     }		

     if($per > 0){
      $tid_comis = $self->add_trans({
      t_name1 => $params->{ct_aid},
      t_name2 => $comis_aid,
      t_currency => $params->{ct_currency},
      t_amnt => $per*$params->{ct_amnt}/100,
      t_comment => 
	"Комиссия$service_title при выводе безнала через фирму $rf->{f_name}(id#$params->{ct_fid}), 
	$params->{ct_comment}",
      });
     }
	      $tid = $self->add_trans({
        	t_name1 => $params->{ct_aid},
		t_name2 => $firms_id,
	    	t_currency => $params->{ct_currency},
	    	t_amnt => $params->{ct_amnt},
	    	t_comment => $params->{ct_comment},
	});
					 
   
     
	
     if($per>0)	
     {
	$service_title=" за услугу $rfs->{fs_name} (id#$rfs->{fs_id})";
     }

     if($params->{ct_ext_commission})
     {
		
	
		$ext_com_id=$self->add_trans({
      			t_name1 => $params->{ct_aid},
      			t_name2 => $comis_aid,
      			t_currency => $params->{ct_currency},
      			t_amnt => $params->{ct_ext_commission},
      			t_comment => "Дополнительная комиссия $service_title при выводе безнала через фирму $rf->{f_name}(id#$params->{ct_fid}), $params->{ct_comment}",
      		});
     }
	##if we are working with request for money and also we need t remember that we work with 
	## positive sums 	
	## because of it we need to update the the account of firm
	if($params->{ct_req} eq 'yes')
	{
		my $currency=lc($params->{ct_currency});
		$dbh->do("UPDATE firms  SET f_$currency=f_$currency-?  WHERE f_id=?",
					          undef,abs($params->{ct_amnt}),$params->{ct_fid});
		
	}
	my $cur = lc($params->{ct_currency});

  	$per+=abs($params->{ct_comis_percent_exchange});
	
	if($params->{ct_req} ne 'yes')
	{
 	
	$dbh->do(qq[UPDATE
	 	cashier_transactions SET
	 	ct_ts=NOW(),ct_comment=?,
	  	ct_oid2=?,		
		ct_status='processed',ct_tid2=?,ct_fid=?,ct_fsid=?,
	  	ct_tid2_comis=?,
		ct_ts2=?,
		ct_ext_commission=?,ct_tid2_ext_com=?,ct_aid=?,ct_comis_percent=?,ct_eid=$eid,ct_req='no' 
		WHERE ct_id=?],
	undef,
	$params->{ct_comment},
	$self->{user_id},
	$tid,
	$params->{ct_fid},
	$params->{ct_fsid},
	$tid_comis,
	$params->{ct_ts2},
	$params->{ct_ext_commission},
	$ext_com_id,$params->{ct_aid},$per,$params->{ct_id});
	
	}
	else
	{
		$dbh->do(qq[UPDATE
	 	cashier_transactions SET
	 	ct_ts=NOW(),ct_comment=?,
	  	ct_oid2=?,		
		ct_status='processed',ct_tid2=?,ct_fid=?,ct_fsid=?,
	  	ct_tid2_comis=?,ct_date=NOW(),ct_ts2=?,
		ct_ext_commission=?,ct_tid2_ext_com=?,ct_aid=?,
		ct_comis_percent=?,ct_eid=$eid,ct_req='no' 
		WHERE ct_id=?],
	undef,$params->{ct_comment},$self->{user_id},
	$tid,
	$params->{ct_fid},$params->{ct_fsid},
	$tid_comis,
	$params->{ct_ts2},
	$params->{ct_ext_commission},
	$ext_com_id,$params->{ct_aid},$per,$params->{ct_id});	
	

	}
	$dbh->do(qq[INSERT $SQL_DELAYED INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
	o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
	result_amnt,ct_comis_percent,ct_ext_commission,
	ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
	select `cashier_transactions`.`ct_id` AS `ct_id`,`cashier_transactions`.`ct_aid` AS `ct_aid`,
	concat(if(of_name IS NOT NULL,of_name,''),' ',`cashier_transactions`.`ct_comment`) AS `ct_comment`,
	`cashier_transactions`.`ct_oid` AS `ct_oid`,
	`operators`.`o_login` AS `o_login`,
	`firms`.`f_id` AS `ct_fid`,
	`firms`.`f_name` AS `f_name`,
	`cashier_transactions`.`ct_amnt` AS `ct_amnt`,
	`cashier_transactions`.`ct_currency` AS `ct_currency`,
	( if((`cashier_transactions`.`ct_eid` is not null),
                if((`cashier_transactions`.`ct_ex_comis_type` = _cp1251'in_rate'),
                ((1 / `exchange_view`.`e_rate`) * ((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_amnt`) -
                (`cashier_transactions`.`ct_amnt` * (`exchange_view`.`e_rate` + 
	((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
	((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100)),
	((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100))) AS `comission`,
	  if((`cashier_transactions`.`ct_eid` is not null),`exchange_view`.`e_amnt2`,
	(`cashier_transactions`.`ct_amnt` - ct_ext_commission + ((`cashier_transactions`.`ct_comis_percent` * `cashier_transactions`.`ct_amnt`) / 100))) AS `result_amnt`,
	 `ct_comis_percent`,
	 -1*`ct_ext_commission`,
	cast(if(isnull(`cashier_transactions`.`ct_ts2`),
	`cashier_transactions`.`ct_ts`,`cashier_transactions`.`ct_ts2`) as date) AS `ct_date`,
	`exchange_view`.`e_currency1` AS `e_currency2`,
	`exchange_view`.`e_rate` AS `rate`,
	`cashier_transactions`.`ct_eid` AS `ct_eid`,
	`cashier_transactions`.`ct_ex_comis_type` AS `ct_ex_comis_type`,if(isnull(`cashier_transactions`.`ct_ts2`),
	`cashier_transactions`.`ct_ts`,`cashier_transactions`.`ct_ts2`) AS `ts`,
	'0000-00-00 00:00:00',
	`cashier_transactions`.`ct_status` AS `ct_status`,
	16777215 
	from 
	((((`cashier_transactions` left join `exchange_view` on(`exchange_view`.`e_id` = `cashier_transactions`.`ct_eid`)) 
	left join `firms` on(`cashier_transactions`.`ct_fid` = `firms`.`f_id`) ) 
	left join `operators` on (`cashier_transactions`.`ct_oid` = `operators`.`o_id`))
    left join out_firms  on (`cashier_transactions`.`ct_ofid` = out_firms.`of_id`)) 	where ((`cashier_transactions`.`ct_amnt` < 0) 
	and (`cashier_transactions`.`ct_status` in (_cp1251'processed'))) 
	AND ct_id=? LIMIT 1],undef,$params->{ct_id});	

	return  $self->ok($params);
	
	

}
sub ok
{
	my $self=shift;
	my $id=shift;
	$self->{endTemplate} = "proto_ok.html" unless($self->{endTemplate});
	my $tmpl=$self->load_tmpl($self->{endTemplate});
    my $output = "";
	
	$self->{tpl_vars}->{a_name}=$proto->{params}->{a_name};
	$self->{tpl_vars}->{a_id}=$proto->{params}->{a_id};
	$self->{tpl_vars}->{id}=$proto->{params}->{id};
	$self->{tpl_vars}->{ct_ts2}=$proto->{params}->{ct_ts2};
	$self->{tpl_vars}->{ct_comment}=$proto->{params}->{ct_comment};
	
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;


}



sub add_many
{
	my $self = shift;
	return $self->add_common_({ext=>1});

}
sub add_common_confirm
{
	my $self = shift;
	return $self->add_common_confirm_({ext=>1});

}




sub add_common_do
{
	my $self=shift;
	my @ct_id=$self->query->param('ct_id');
	my $exchange_yes=$self->query->param('exchange_yes');
	my $params={};
	my $ct_aid=$self->query->param('ct_aid');
	my $light_rate=$self->query->param('rate');
	my $source_currency=$self->query->param('currency');
	my $ct_ext_comission=$self->query->param('ct_ext_comission');
	my $ct_fsid=$self->query->param('ct_fsid');
    my $ra  = $dbh->selectrow_hashref("SELECT * FROM accounts WHERE  a_id = ".sql_val( $ct_aid ));

	$params->{ct_fsid}=$ct_fsid;
	$params->{ct_comis_percent}=$self->query->param('ct_comis_percent');

	$params->{ct_ts2}=$self->query->param('ct_ts2');
	
    $params->{ct_comis_percent_exchange}=$self->query->param('ct_comis_percent_exchange');

    $params->{ct_comis_percent_in_exchange}=$self->query->param('ct_comis_percent_in_exchange');

    $params->{ct_ext_commission_perc}=$self->query->param('ct_comis_percent_in');

	$params->{ct_comis_percent_exchange}=~s/,/\./g;

	$params->{ct_comis_percent}=1*$params->{ct_comis_percent};

	return	error_process $self, "Вы не выбрали карточку \n " unless($ra);
	$params->{ct_ext_commission}=$ct_ext_comission*1;

    die "Процент комиссии слишком большой\n" if(abs($params->{ct_comis_percent_exchange})>2*$ETALON_VALUE_COMIS||abs($params->{ct_comis_percent})>2*$ETALON_VALUE_COMIS);
	$params->{ct_aid} =$ra->{a_id};

	
	if($exchange_yes)
	{
		return 	error_process $self, "Не задан курс обмена \n"	unless($light_rate);
		return 	error_process $self, "Не задана валюта обмена \n" unless($avail_currency->{$source_currency});

		my $currencies=$dbh->selectrow_array(q[SELECT 
		ct_currency FROM cashier_transactions 
		WHERE ct_id=?],undef,$ct_id[int(rand(scalar(@ct_id)))]);
		die "Выберите разные валюты \n" if($source_currency eq $currencies);
		
	}
	$params->{currency}=$source_currency;
	$params->{rate}=$light_rate;	
	$params->{exchange_yes}=$exchange_yes;
	$params->{non_redirect}=1;
		foreach(@ct_id)
		{
			$_=~s/["' \\]//g;
			next unless(1*$_);### ;)) 
			$params->{ct_id}=$_;
 			$self->proto_add_edit_trigger($params);
			$params->{ct_comment}=undef;
			
		
  		}
	$self->{endTemplate} = "proto_ok.html" unless($self->{endTemplate});
    my $tmpl=$self->load_tmpl($self->{endTemplate});
    my $output = "";
	$self->{tpl_vars}->{a_name}=$ra->{a_name};
	$self->{tpl_vars}->{a_id}=$ra->{a_id};
	$self->{tpl_vars}->{add_many}=1;
	#$self->{tpl_vars}->{a_name}=$id->{a_name};
	#$self->{tpl_vars}->{a_id}=$id->{a_id};
	$self->{tpl_vars}->{id}=\@ct_id;
	$self->{tpl_vars}->{ct_ts2}=$params->{ct_ts2};
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	my_log($self,$TIMER->stop);
	return $output;
}






1;
