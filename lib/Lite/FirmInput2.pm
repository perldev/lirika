package Lite::FirmInput2;
use strict;
use base 'CGIBaseLite';
use SiteConfig;
use SiteDB;
use SiteCommon;

my $proto;
sub get_right{
my $self=shift;
$proto={
  'table'=>"cashier_transactions",  
  'template_prefix'=>"firm_in2",
  'page_title'=>'Выписки',
  'extra_where'=>q[ ct_amnt>0 AND ct_fid>0 AND ct_status!='deleted' ],
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
			var id_val=document.getElementById('ct_aid').value;
			var commission_percent;
			if(!id_val)
			document.getElementById('ct_aid').value=document.getElementById('ct_aid__select').value;
				var selected_service=document.getElementById('ct_fsid').value;
			
			if(!selected_service)
			{
					change_commission();
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
			//calculate the commssions
					
					set_element('ct_comis_percent',val);
					change_commission();
					
				
			}
		}
		function change_commission()
		{
					var amnt=get_element('ct_amnt',1);
					commission_percent=get_element('ct_comis_percent',1);
					set_element('ct_comis_percent',commission_percent);
					var amnt1=(amnt*commission_percent)/100;
					amnt1=Math.ceil(amnt1*100)/100;
					set_element('commission',amnt1);
					set_element('common_sum',(1*amnt-amnt1*1));
					return;
		}
		if(document.getElementById('__confirm'))
		{
  		 	change_commission();
		 
		}else
		{
			change_services();
		}
	
	],

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
   no_base=>0 ,etalon=>$ETALON_VALUE_COMIS},
	
    {'field'=>"commission", "title"=>"Сумма комиссии ",'default'=>"0",'system'=>1,"no_add_edit"=>1,no_base=>1},
    {'field'=>"common_sum", "title"=>"Общая сумма",'default'=>"0",'system'=>1,"no_add_edit"=>1,no_base=>1},	
    {'field'=>"ct_currency", "title"=>"Валюта", 'filter'=>"=", "type"=>"select"
     , "titles"=>\@currencies
     , "no_add_edit"=>1,},
#     {'field'=>"ct_eid",'title'=>'Произвести обмен','system'=>1,"category"=>"exchange",'value'=>'ct'},	

    {'field'=>"ct_comment", "title"=>"Назначение", "no_add_edit"=>0,'filter'=>'like'},

    {'field'=>"ct_oid", "title"=>"Оператор"
      , "no_add_edit"=>1, "category"=>"operators"
    },
    #{'field'=>"ct_tid", "title"=>"Транзакция", "no_add_edit"=>1,},


    {'field'=>"ct_status", "title"=>"Статус проведения"
     , "type"=>"select"
     , "titles"=>[
        {'value'=>"created", 'title'=>"в процессе"},
        {'value'=>"processed", 'title'=>"проведен"},
     ]
     , 'filter'=>"="
     , "no_add_edit"=>1
     , "no_view"=>1
    },


    {'field'=>"ct_oid2", "title"=>"Оператор 2"
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

return 'firm_in2';
}
sub setup
{
  my $self = shift;
#  $SIG{__DIE__}=\&proto_die_catcher;   
  $self->run_modes(
     'edit' => 'edit',
     'add_many'=>'add_many',
     'add_common_confirm'=>'add_common_confirm',
     'add_common_do'=>'add_common_do'
  );
}
sub edit
{
   my $self = shift; 
   

   my $param=$self->query->param('action');
   my $confirm=$self->query->param('__confirm');
   my %params;
   map{ $params{$_}=$self->query->param($_) }  $self->query->param();
   delete $params{'apply'};
   delete $params{'do'};
   delete $params{'__confirm'};	
   return $self->proto_add_edit('edit', $proto);
}

sub proto_add_edit_trigger{
  my $self=shift;
  my $params = shift;
  if($params->{step} eq 'before'){
	  my $tid = "NULL";
   my $tid_comis = "NULL";
   my $eid=undef;
   my $aid = $self->query->param('ct_aid');
   my $fsid = $self->query->param('ct_fsid');
  $proto->{params}={};
  $proto->{params}->{ct_ts2}=$self->query->param('ct_ts2');
  $proto->{params}->{ct_comment}=$self->query->param('ct_comment');
##exchange of 
   my $per;	
   my $per_exchange;
   my $exchange_yes = $self->query->param('exchange_yes');

   if($aid == $svoj_id){
     $self->query->param('ct_fsid'=>'');
   }else{     
     my $id = $self->query->param('id');

     	$aid=get_real_aid($aid);

	my $r=$dbh->selectrow_hashref(q[SELECT 
			* FROM cashier_transactions 
			WHERE ct_id=? AND ct_status='created'],undef,$id);
	
	die "Выберите разные валюты \n" if($exchange_yes&&$self->query->param('currency') eq $r->{ct_currency});
	
##protections from double clicking
	my $protection=$dbh->do(q[UPDATE cashier_transactions 
			       SET ct_status='processing',ct_aid=?
   		      	         WHERE ct_id=? AND ct_status='created' 
			 ],undef,$aid,$id); 
	if($protection ne '1')
	{
		
		if($params->{non_redirect})
		{
			##!! only for using in common identification
			return 0;
		}else
		{
			$self->header_type('redirect');
			return $self->header_add(-url=>'?#'.$params->{ct_id});
		}
	}

	
       my $amnt = $r->{'ct_amnt'};
       my $currency = $r->{'ct_currency'};
		      my $comment =undef;# $self->query->param('ct_comment'); 
      $comment=$r->{ct_comment}	unless($comment);
      my $fid = $r->{'ct_fid'};     
		
      my $ra  = $dbh->selectrow_hashref("SELECT * FROM accounts WHERE  a_id = ".sql_val( $aid ));
      $proto->{params}->{a_name}=$ra->{a_name};
      $proto->{params}->{a_id}=$ra->{a_id};
      $proto->{params}->{id}=$id;

	  my $rfs;     
	  $rfs = $dbh->selectrow_hashref("SELECT * FROM firm_services,client_services WHERE cs_aid=? AND
	  		       fs_id=cs_fsid AND cs_fsid=".sql_val( $fsid ),undef,$aid) if($fsid);
			       
	    my $rf = $dbh->selectrow_hashref("SELECT * FROM firms WHERE f_id = ".sql_val( $fid ));
	     $per = $self->query->param('ct_comis_percent')+0;
	   
	     $per_exchange = $self->query->param('ct_comis_percent_exchange')+0;
		$per_exchange=~s/,/\./g;
	    $per=abs($per);
	

	if($per > 0){
	#  die "$comis_aid,$aid";
             $tid_comis = $self->add_trans({
		           	t_name1 => $aid,
		         	t_name2 => $comis_aid,
		       		t_currency => $currency,
	             		t_amnt => $per*($amnt/100),
	           		t_comment => "Комиссия $per\% за услугу $rfs->{fs_name}
	         		(id#$rfs->{fs_id}) при вводе безнала через фирму $rf->{f_name}(id#$fid), $comment",
	       });
        }
											



	
	

     $tid = $self->add_trans({
      		t_name1 => $firms_id,
    		t_name2 => $aid,
      		t_currency => $currency,
      		t_amnt => $amnt,
      		t_comment => $comment,
     
      });
      if($exchange_yes)
      {
		
		$eid=$self->add_exc(
		{
			e_date=>$r->{ct_date},
			a_id=>$aid,
			e_currency1=>$currency,
			e_currency2=>$self->query->param('currency'),
			rate=>$self->query->param('rate'),
			type=>'auto',
			e_amnt1=>$amnt-$per*($amnt/100),
			e_comment=>'Автообмен при индентификации прихода по курсу '.$self->query->param('rate')
      		});
		
		$dbh->do(q[UPDATE cashier_transactions SET ct_eid=? WHERE ct_id=?],undef,$eid,$id);
	}else
	{
		$eid='NULL';
	}
	##if we are working with request for money and also we need t remember that we work with 
	## positive sums 	
	## because of it we need to update the the account of firm
	if($r->{ct_req} eq 'yes')
	{
		my $currency=lc($r->{ct_currency});
		$dbh->do("UPDATE firms  SET f_$currency=f_$currency+?  WHERE f_id=?",
					          undef,abs($r->{ct_amnt}),$r->{ct_fid});	
		$dbh->do(q[UPDATE cashier_transactions SET ct_date=NOW(),ct_req='no' WHERE ct_id=?],undef,$id);		
	}


     

    
    }
	
   foreach my $row( @{$params->{proto}->{fields}} ) {
     if($row->{field} eq 'ct_oid2'){
       $row->{expr} = $self->{user_id}
     }elsif($row->{field} eq 'ct_tid2'){
       $row->{expr} = $tid;
     }elsif($row->{field} eq 'ct_tid2_comis'){
       $row->{expr} = $tid_comis;
     }elsif($row->{field} eq 'ct_ts2'){
       $row->{expr} = "NOW()";
     }elsif($row->{field} eq 'ct_status'){
       $row->{expr} = "'processed'";
     }elsif($row->{field} eq 'ct_comis_percent')
     {
     	$row->{expr}=$per_exchange+$per;
	$row->{no_add_edit}=1;
     }	
   }
   return 1;
  }elsif($params->{step} eq 'operation'){

	$dbh->do($params->{sql});
   	my $id=$self->query->param('id');
	unless($dbh->selectrow_array(q[SELECT ct_id 
	FROM accounts_reports_table WHERE ct_id=? AND ct_ex_comis_type='input'],undef,$id))
	{
    $dbh->do(qq[INSERT  $SQL_DELAYED INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
	o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
	result_amnt,ct_comis_percent,ct_ext_commission,
	ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
	SELECT `cashier_transactions`.`ct_id` AS `ct_id`,`cashier_transactions`.`ct_aid` 
	AS `ct_aid`,
	concat(if(of_name IS NOT NULL,of_name,''),' ',`cashier_transactions`.`ct_comment`) AS `ct_comment`,
	`cashier_transactions`.`ct_oid` AS `ct_oid`,
	`operators`.`o_login` AS `o_login`,
	`firms`.`f_id` AS `ct_fid`,
	`firms`.`f_name` AS `f_name`,
	`cashier_transactions`.`ct_amnt` AS `ct_amnt`,
	`cashier_transactions`.`ct_currency` AS `ct_currency`,
	(-(1) * if((`cashier_transactions`.`ct_eid` is not null),
	if((`cashier_transactions`.`ct_ex_comis_type` = _cp1251'in_rate'),
	((1 / `exchange_view`.`e_rate`) * ((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_amnt`) -
	 (`cashier_transactions`.`ct_amnt` * (`exchange_view`.`e_rate` + 
	((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
	((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100)),
	((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100))) AS `comission`,
	if((`cashier_transactions`.`ct_eid` is not null),`exchange_view`.`e_amnt2`,
	(`cashier_transactions`.`ct_amnt` - ((`cashier_transactions`.`ct_comis_percent` * `cashier_transactions`.`ct_amnt`) / 100))) AS `result_amnt`,
	`cashier_transactions`.`ct_comis_percent` AS `ct_comis_percent`,
	`cashier_transactions`.`ct_ext_commission` AS `ct_ext_commission`,cast(if(isnull(`cashier_transactions`.`ct_ts2`),
	`cashier_transactions`.`ct_ts`,`cashier_transactions`.`ct_ts2`) as date) AS `ct_date`,
	`exchange_view`.`e_currency2` AS `e_currency2`,
	`exchange_view`.`e_rate` AS `rate`,
	`cashier_transactions`.`ct_eid` AS `ct_eid`,
	`cashier_transactions`.`ct_ex_comis_type` AS `ct_ex_comis_type`,if(isnull(`cashier_transactions`.`ct_ts2`),
	`cashier_transactions`.`ct_ts`,`cashier_transactions`.`ct_ts2`) AS `ts`,
	'0000-00-00 00:00:00',
	`cashier_transactions`.`ct_status` AS `ct_status`,
	16777215 
	from ((((`cashier_transactions` 
	    left join `exchange_view` on (`exchange_view`.`e_id` = `cashier_transactions`.`ct_eid`) ) 
	    left join `firms` on (`cashier_transactions`.`ct_fid` = `firms`.`f_id`) ) 
	    left join `operators` on(`cashier_transactions`.`ct_oid` = `operators`.`o_id`))
        left join out_firms on (`cashier_transactions`.`ct_ofid` = `out_firms`.`of_id`))
	where (1  AND ct_id=? AND (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` 
	in (_cp1251'processed'))) LIMIT 1],undef,$id);	
	}
	return $self->ok({a_id=>$proto->{params}->{a_id},
	a_name=>$proto->{params}->{a_name}
	});
	


  }

}
sub ok
{
	my $self=shift;
	my $id=shift;
	use Data::Dumper;
	$self->{endTemplate} = "proto_ok.html" unless($self->{endTemplate});
	#die(Dumper($proto->{params}));
	my $tmpl=$self->load_tmpl($self->{endTemplate});
    my $output = "";
	
#	$self->{tpl_vars}->{ct_fid}=$id->{ct_fid};

#	$self->{tpl_vars}->{ct_currency}=$id->{ct_currency};

	$self->{tpl_vars}->{a_name}=$id->{a_name};
	$self->{tpl_vars}->{a_id}=$id->{a_id};
	$self->{tpl_vars}->{id}=$proto->{params}->{id};
	$self->{tpl_vars}->{ct_ts2}=$proto->{params}->{ct_ts2};
	$self->{tpl_vars}->{ct_comment}=$proto->{params}->{ct_comment};
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;


}


sub add_many
{
	my $self = shift;
	return $self->add_common_();

}
sub add_common_confirm
{
	my $self = shift;
	return $self->add_common_confirm_();

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
	my $ct_fsid=$self->query->param('ct_fsid');
	my $ct_ts2=$self->query->param('ct_ts2');
	my $per=$self->query->param('ct_comis_percent');
	my $per_exch=$self->query->param('ct_comis_percent_exchange');
    my $per_in=$self->query->param('ct_comis_percent_in');
    my $per_exch_in=$self->query->param('ct_comis_percent_in_exchange');
    $per_exch=~s/,/\./g;
    $per=~s/,/\./g;
    $per_in=~s/,/\./g;
	$per_exch_in=~s/,/\./g;
    $self->query->param('ct_comis_percent',$per);
    $self->query->param('ct_comis_percent_exchange',$per_exch);
    $self->query->param('ct_comis_percent_in_exchange',$per_exch_in);
	$self->query->param('ct_comis_income',$per_in);

	
	$per+=$per_exch;
	##checking required params in order that proto_add_edit_trigger not crashed
      my $ra  = $dbh->selectrow_hashref("SELECT * FROM accounts WHERE  a_id = ".sql_val( $ct_aid ));

	die "Вы не выбрали карточку \n " unless($ra);
    
    die "Процент комиссии слишком большой\n" if(abs($per_exch)>2*$ETALON_VALUE_COMIS||abs($per)>2*$ETALON_VALUE_COMIS||abs($per_in)>2*$ETALON_VALUE_COMIS||abs($per_exch_in)>2*$ETALON_VALUE_COMIS);
	$self->{tpl_vars}->{a_name}=$ra->{a_name};
	$self->{tpl_vars}->{a_id}=$ra->{a_id};

	if($exchange_yes)
	{
	
			
			die "Не задан курс обмена \n"	unless($light_rate);
			die "Не задана валюта обмена \n" unless($avail_currency->{$source_currency});
			my $currencies=$dbh->selectrow_array(q[SELECT 
			ct_currency FROM cashier_transactions 
			WHERE ct_id=?],undef,$ct_id[int(rand(scalar(@ct_id)))]);
			die "Выберите разные валюты \n" if($source_currency eq $currencies);
			
	}
	my $iter =0;
	foreach(@ct_id)
	{
		$_=~s/["' \\]//g;
		next unless(1*$_);### ;)) 
 		$self->query->param('ct_comment',undef);
		$self->query->param('id',$_);
		
		$params->{step}='before';
		$params->{ct_id}=$_;
		$params->{non_redirect}=1;
		$params->{proto}={fields=>[ {field=>'ct_tid2',expr=>''}, {field=>'ct_tid2_comis',expr=>''} ] };
		


		##(( must be there
		if($self->proto_add_edit_trigger($params))
		{

			$dbh->do("UPDATE cashier_transactions SET
		 		ct_ts2=current_timestamp,
		 		ct_status='processed',
				ct_fsid=?,
				ct_aid=?,
				ct_oid2=?,
				ct_tid2=?,
				ct_tid2_comis=?,
				ct_comis_percent=?,
				ct_req='no',
				ct_ts2=?
				WHERE 
				 ct_status='processing' AND ct_id=?
		",undef,$ct_fsid,$ct_aid,$self->{user_id},$params->{proto}->{fields}->[0]->{expr},
		0 ,$per,$ct_ts2,$_);
		
		$dbh->do(qq[INSERT $SQL_DELAYED INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,col_status,ct_status,col_color)
		SELECT `cashier_transactions`.`ct_id` AS `ct_id`,`cashier_transactions`.`ct_aid` 
		AS `ct_aid`,
         concat(if(of_name IS NOT NULL,of_name,''),' ',`cashier_transactions`.`ct_comment`) AS `ct_comment`,
		`cashier_transactions`.`ct_oid` AS `ct_oid`,
		`operators`.`o_login` AS `o_login`,
		`firms`.`f_id` AS `ct_fid`,
		`firms`.`f_name` AS `f_name`,
		`cashier_transactions`.`ct_amnt` AS `ct_amnt`,
		`cashier_transactions`.`ct_currency` AS `ct_currency`,0,
		`cashier_transactions`.`ct_amnt`  AS `result_amnt`,
		0 AS `ct_comis_percent`,
		 0  AS `ct_ext_commission`,cast(if(isnull(`cashier_transactions`.`ct_ts2`),
		`cashier_transactions`.`ct_ts`,`cashier_transactions`.`ct_ts2`) as date) AS `ct_date`,
		`exchange_view`.`e_currency2` AS `e_currency2`,
		`exchange_view`.`e_rate` AS `rate`,
		`cashier_transactions`.`ct_eid` AS `ct_eid`,
		`cashier_transactions`.`ct_ex_comis_type` AS `ct_ex_comis_type`,if(isnull(`cashier_transactions`.`ct_ts2`),
		`cashier_transactions`.`ct_ts`,`cashier_transactions`.`ct_ts2`) AS `ts`,
		`cashier_transactions`.`col_status` AS `col_status`,
		`cashier_transactions`.`col_ts` AS `col_ts`,
		`cashier_transactions`.`ct_status` AS `ct_status`,
		`cashier_transactions`.`col_color` AS `col_color` 
		from ((((`cashier_transactions` 
		left join `exchange_view` on((`exchange_view`.`e_id` = `cashier_transactions`.`ct_eid`))) 
		left join `firms` on((`cashier_transactions`.`ct_fid` = `firms`.`f_id`))) 
		left join `operators` on((`cashier_transactions`.`ct_oid` = `operators`.`o_id`)))
        left join out_firms on (`cashier_transactions`.`ct_ofid` = `out_firms`.`of_id`))
		where (1  AND ct_id=? AND (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` 
		in (_cp1251'processed'))) LIMIT 1],undef,$_);	
	


		}
		
  	}

    my_log($self,$TIMER->stop);
	$self->{endTemplate} = "proto_ok.html" unless($self->{endTemplate});
	my $tmpl=$self->load_tmpl($self->{endTemplate});
    my $output = "";
	
	$self->{tpl_vars}->{add_many}=1;
	#$self->{tpl_vars}->{a_name}=$id->{a_name};
	#$self->{tpl_vars}->{a_id}=$id->{a_id};
	$self->{tpl_vars}->{id}=\@ct_id;
	$self->{tpl_vars}->{ct_ts2}=$ct_ts2;
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;

}





sub proto_die_catcher
{
        return if $^S; # for eval die
        my $msg=join ',', @_;
        print "Content-type: text/html; charset=cp1251\n\n";
	my @arr=split(':',$msg);
	$msg=$arr[1];
	$msg=~s/at(.*)//;
	require Template;
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
