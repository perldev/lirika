package Oper::FirmOutput;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
use Documents;
my $firm_services = undef;
# 
# java_script_action
# java_script
my $proto;
sub get_right
{       
        my $self=shift;

        $proto={
        'table'=>"cashier_transactions",  
        'template_prefix'=>"firm_out",
        'extra_where'=>"ct_amnt < 0 AND ct_fid>0 AND ct_status!='deleted'",
        'page_title'=>'�������� �������',
        'need_confirmation'=>1,
        'id_field'=>'ct_id',
        'sort'=>' ct_date DESC',
        'init_java_script'=>q[
		        
        
        
		        var REQ;
		        var READY_STATE_COMPLETE=4;
		        var services_percents=new Array();
		        var start_;
		        function getHttp()
		        {
				        var req=null;
				        if(window.XMLHttpRequest)
				        {
						        
					        req=new XMLHttpRequest();
					        return req;
				        }else if (window.ActiveXObject)	
				        {
					        req=new ActiveXObject("Microsoft.XMLHTTP");
					        return req;
				        }else
				        {
					        alert("sorry,change you browser please");
					        return req;
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
					        if(percent||percent==0)
					        {
					    	    set_element('ct_comis_percent',percent);
					        
					        }
					        var amnt;
					        amnt=get_element('ct_amnt');
					        var ext_com;
					        ext_com=get_element('ct_ext_commission',1);

                            ext_com_perc=get_element('ct_ext_commission_perc',1);

					        var val;
					        val=get_element("ct_comis_percent",1);
					        amnt1=(amnt*val)/100;
					        amnt1=Math.ceil(amnt1*100)/100;
                            var amnt2=(amnt*ext_com_perc)/100;
                            set_element('commission',amnt1);
					        set_element('ct_ext_incom',amnt2);
					        amnt=1*amnt+amnt1*1+ext_com*1+1*amnt2;
				            set_element('common_sum',Math.ceil(amnt*100)/100);
        
		        
	        }
        //	change_services();
        
	        ],
        
        'fields'=>[
            {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1,filter=>'=','filter_invisible'=>'1'},    
            {'field'=>"ct_date","no_add_edit"=>1, "no_view"=>1, "title"=>"����", 'filter'=>"time"},
            {'field'=>"ct_ts","no_add_edit"=>1, "no_view"=>1, "title"=>"���� ���", },
            {'field'=>"ct_tid2_ext_com","no_add_edit"=>1, "no_view"=>1},
        
         {
             'field'=>"ct_ofid",
             alias=>'out_firm',
            "title"=>"����� �������", 
             select_search=>1,
             type=>'select',
             category=>'out_firms',
             no_add_edit=>1,
             filter=>'=',
             titles=>&get_out_firms(1)
            },
       
    
            {
              'field'=>"ct_ofid","title"=>"����",
               select_search=>1,
               type=>'select',
              no_add_edit=>1,
              category=>'out_firms_okpo',filter=>'=',
               titles=>&get_out_firms_okpo(1)
            },
            {'field'=>"ct_fid", "title"=>"�����", "category"=>"firms", 'filter'=>"="
            , "type"=>"select","no_add_edit"=>1,
            },    
            {'field'=>"ct_aid", "title"=>"��������", "category"=>"accounts",'value'=>9},
            {'field'=>"ct_fsid", "title"=>"������","category"=>"firm_services", "type"=>"select", "may_null"=>1,
            java_script_action=>'onchange="change_services()"',
            "titles"=>$firm_services},
            {'field'=>"ct_currency", "title"=>"������", 'filter'=>"=",
            "no_add_edit"=>1,
            'filter'=>"=", "type"=>"select", "titles"=>\@currencies	     
            },
            {
	        'field'=>"ct_amnt", "title"=>"�����", 'filter'=>"=", 'op'=>'-', "positive"=>1
            },
            {'field'=>"ct_comis_percent","title"=>"��������%",'default'=>"0",
            java_script_action=>'onkeyup="change_comission()"',etalon=>'2'},
        
            {'field'=>"commission", "title"=>"�������� ",'default'=>"0",'system'=>1,"no_add_edit"=>1,no_base=>1},
        
            {'field'=>"common_sum", "title"=>"����� �����",'default'=>"0",'system'=>1,"no_add_edit"=>1,no_base=>1},
            {'field'=>"ct_eid",'title'=>'���������� �����','system'=>1,"category"=>"exchange",'value'=>'ct'},	
        
	        {'field'=>"ct_comment","title"=>"����������", 'default'=>"����� �������",'filter'=>'like'},
            
           

            {'field'=>"ct_ts2","title"=>"���� ���������", category=>'date'},
            
                    


            {
              'field'=>"ct_oid", "title"=>"��������"
            , "no_add_edit"=>1, "category"=>"operators"
            },


            {
            'field'=>"ct_ext_commission","title"=>"�������������� ��������",
            'default'=>"0",
            'java_script_action'=>'onkeyup="change_comission()"'

            },
            {'field'=>"ct_oid2", "title"=>"�������� ����������"
            , "no_add_edit"=>1, "category"=>"operators",no_view=>1
            },
            #{'field'=>"ct_tid", "title"=>"����������", "no_add_edit"=>1,},
        
        
             {
        'field'=>"ct_status", "title"=>"������ ����������"
        , "type"=>"select"
        , "titles"=>[
            {'value'=>"created", 'title'=>"� ��������"},
            {'value'=>"processed", 'title'=>"��������"},
        ]
        , 'filter'=>"="
        , "no_add_edit"=>1
        , "no_view"=>1
        },
        
            {'field'=>"ct_tid2", "title"=>"���������� 2"
            , "no_add_edit"=>1
            ,"no_view"=>1
            },
            {
	        
	        'field'=>"ct_tid2_comis", "title"=>"���������� 2, ��������"
            , "no_add_edit"=>1
            ,"no_view"=>1
            },
            {
            
            'field'=>"ct_tid2_comis", "title"=>"���������� 2, ��������"
            , "no_add_edit"=>1
            ,"no_view"=>1
            },
#             { 
#                 'field'=>"ct_ext_commission_perc",
#                 title=>'������� � ���������',
#                 java_script_action=>'onkeyUp="change_comission()"',
#                 'system'=>1,
#             },
#             { 
#                 'field'=>"ct_ext_incom",
#                 'title'=>'����� � ���������',
#                 'system'=>1,"no_add_edit"=>1,no_base=>1
#             },
        
        
        
        ],
        };

        return 'firm_out';
}
sub setup
{
  my $self = shift;
   $self->start_mode('list');
  $self->run_modes(
    	'AUTOLOAD'   => 'list',
    	'list' => 'list',
    	'edit' => 'edit',
    	'del'  => 'del',
    	'add_common'=>'add_common',
    	'add_common_confirm'=>'add_common_confirm',
    	'add_common_do'=>'add_common_do',
  );
}
sub add_common
{
	my $self=shift;

	return $self->add_common_({ext=>1});

}
sub add_common_confirm
{
	my $self=shift;
	return $self->add_common_confirm_({ext=>1});

}



sub list
{
   my $self = shift;
   
   return $self->proto_list_short($proto);
}
sub edit
{
	my $self = shift;
    $proto->{fields}->[5]->{no_view}='1';

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
        
        return $self->error(q[�� ����� ���� �������������� � ��������� �������� ])    if(($params{ct_ext_commission_perc}&&$params{ct_ext_commission})||($params{ct_comis_percent_in_exchange}&&$params{ct_ext_commission}));
        
        
        $params{ct_ext_commission_perc}=to_prec6($params{ct_ext_commission_perc});
    
        if($params{ct_ext_commission_perc}&&!$account_->{a_incom_id}){
            return $self->error("� ������ ��������� ��� ���������");                

        }
        if($params{ct_ext_commission_perc}){
            $params{ct_ext_commission}=($params{ct_amnt}/100)*$params{ct_ext_commission_perc};
            $self->query->param('ct_ext_commission',$params{ct_ext_commission});
        }

		my $percent=$params{ct_comis_percent};

		$self->{tpl_vars}->{ct_comis_percent_exchange}=$params{ct_comis_percent_exchange};

        $self->{tpl_vars}->{ct_comis_percent_in_exchange}=$params{ct_comis_percent_in_exchange};
		$params{ct_id}=$params{id};

		$self->{tpl_vars}->{ct_currency}=$conv_currency->{$ref->{ct_currency}};

		$self->{tpl_vars}->{ct_ts2}=$params{ct_ts2};
		$self->{tpl_vars}->{ct_ts2_unformat}=format_date($params{ct_ts2});

          
       
		$self->{tpl_vars}->{page_title}="������������� �����";
		
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

        ###checking for mines
         if($params{exchange_yes}){
            
            my $currency=$params{currency};
             $self->{tpl_vars}->{error_msg}="������ ������ �������� ����� � ����� \n" if($account_->{ac_id}==$CLIENT_CATEGORY&&($account_->{lc($currency)}-$self->{tpl_vars}->{exchange_sum})<0);
        }else
        {
                 
            my $currency=$conv_currency->{$ref->{ct_currency}};
            $params{ct_amnt}=~s/[ ]//g;
            $params{ct_amnt}=~s/[,]/\./g;
            $self->{tpl_vars}->{error_msg}="������ ������ �������� ����� � ����� \n" if($account_->{ac_id}==$CLIENT_CATEGORY&&($account_->{lc($currency)}-$params{ct_amnt})<0);


        }
       

		map {$self->{tpl_vars}->{$_}=$params{$_}} keys %params; 
		
		my $tmpl=$self->load_tmpl('firm_output_confirm.html');
		my $output='';
         my_log($self,$TIMER->stop);

		$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
		return $output;

	}elsif($action eq 'apply'&&$param)
	{
		$params{update}=1;
		
		my $exchange_yes=$self->query->param('exchange_yes');
        my $comis=$self->query->param('ct_comis_percent');

		my $ct_aid=$self->query->param('ct_aid');
		my $light_rate=$self->query->param('rate');
		my $source_currency=$self->query->param('currency');
		$ct_aid=$dbh->selectrow_array('SELECT a_id FROM accounts WHERE a_id=?',undef,$ct_aid);
		return error_process $self,"�� �� ������� �������� \n " unless($ct_aid);
        if(abs($comis)>$ETALON_VALUE_COMIS*2)
        {
            return error $self, "���� �������� ������� ������ ���������� �������� \n";
        }
		if($exchange_yes)
		{
					
					
			return error_process $self, "�� ����� ���� ������ \n"	unless($light_rate);
			return error_process $self, "�� ������ ������ ������ \n" unless($avail_currency->{$source_currency});
			

 			my $currencies=$dbh->selectrow_array(q[SELECT 
 			ct_currency FROM cashier_transactions 
 			WHERE ct_id=?],undef,$params{id});
 			return error_process $self, "�������� ������ ������ \n" if($source_currency eq 
 			$currencies);

 
					
		}

		return $self->proto_add_edit_trigger(\%params);	
	
	}

	
  return $self->proto_add_edit('edit', $proto);

}
sub del
{
   my $self = shift;
   return $self->proto_action('del', $proto);

}


sub proto_add_edit_trigger{
  	
	my $self=shift;
  	my $params = shift;    
   	my $tid = 'NULL';
   	my $tid_comis = 'NULL';
   	my $ext_com_id='NULL';
   	my $eid='NULL';
	require POSIX;

    my ($comis_in,$comis,$real_rate,$result_rate)=(0,0,0,0);

	my $ra  = get_account_name($params->{ct_aid});
    my $result_amnt=0;
    


    if(!$ra->{a_incom_id}&&$params->{ct_ext_commission_perc}>0){
         die "� ������ ��������� ��� ���������";
    }
	
	die "�������� ������ ������ \n" if(defined $params->{exchange_yes}&&$params->{currency} eq 
	$params->{ct_currency});	

	###protection from twice runs
	my $protection=$dbh->do(q[UPDATE cashier_transactions 
			                    SET ct_status='processing'
   		      	                WHERE ct_id=? AND ct_status='created' 
			 ],undef,$params->{ct_id}); 
	
	if($params->{non_redirect}&&$protection ne '1')
	{
		return 0;
	}elsif($protection ne '1'){
		
		$self->header_type('redirect');
    		return $self->header_add(-url=>'?#'.$params->{ct_id});
	}
	
	
	
	
		($params->{ct_fid},$params->{ct_currency},$params->{ct_ts},
		$params->{ct_currency},$params->{ct_amnt},$params->{ct_comment_},$params->{ct_req})=$dbh->selectrow_array(q[SELECT
            ct_fid,ct_currency,
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
     my $per=1*($params->{ct_comis_percent});
     my $service_title='';

  

    
   $comis=$per*$params->{ct_amnt}/100;
   $real_rate=$self->calculate_exchange(0,$params->{rate},$params->{ct_currency},$params->{currency}) if(defined $params->{exchange_yes});

    if($params->{ct_comis_percent_exchange}>0||$params->{ct_comis_percent_exchange}<0){
        $per+=$params->{ct_comis_percent_exchange};
        $comis+=($real_rate*$params->{ct_amnt}-$params->{ct_amnt}*($real_rate-($real_rate/100)*$params->{ct_comis_percent_exchange}))/$real_rate;
   }


   if(($per>0||$per<0)&&0){
            $service_title=" $per\% �� ������ $rfs->{fs_name} (id#$rfs->{fs_id})";
            $tid_comis = $self->add_trans({
	                    t_name1 => $params->{ct_aid},
                            t_name2 => $comis_aid,
                            t_currency => $params->{ct_currency},
                            t_amnt => $comis,
                            t_comment =>"��������$service_title ��� ������ ������� ����� ����� $rf->{f_name}(id#$params->{ct_fid}), 
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
					    
#         if($params->{ct_ext_commission_perc}>0||$params->{ct_comis_percent_in_exchange}>0){
        if($params->{ct_comis_percent_in_exchange}>0||$params->{ct_comis_percent_in_exchange}<0){
            $service_title='�� ��������� ';
            $params->{ct_ext_commission}=0;
        }
        if($params->{ct_ext_commission_perc}>0&&0){
            $params->{ct_ext_commission}+=$params->{ct_ext_commission_perc}*$params->{ct_amnt}/100;
        }

        if($params->{ct_comis_percent_in_exchange}>0||$params->{ct_comis_percent_in_exchange}<0){
            $params->{ct_ext_commission}+=($real_rate*$params->{ct_amnt}-$params->{ct_amnt}*($real_rate-($real_rate/100)*$params->{ct_comis_percent_in_exchange}))/$real_rate;
        } 
     
	
     
#      if($params->{ct_ext_commission}>0||$params->{ct_ext_commission_perc}>0){
      if(($params->{ct_ext_commission}>0||$params->{ct_ext_commission}<0)&&0){

        my $to_id=$comis_aid;
# 		$to_id=$ra->{a_incom_id}  if($params->{ct_ext_commission_perc}||$params->{ct_comis_percent_in_exchange});
	
		$ext_com_id=$self->add_trans({
      			t_name1 => $params->{ct_aid},
      			t_name2 => $to_id,
      			t_currency => $params->{ct_currency},
      			t_amnt => $params->{ct_ext_commission},
      			t_comment => "�������������� �������� $service_title ��� ������ ������� ����� ����� $rf->{f_name}(id#$params->{ct_fid}), $params->{ct_comment}",
      		});
     }
     $result_amnt=-1*($params->{ct_amnt}+$params->{ct_ext_commission}+$comis);
    
     my $rate=$params->{rate};
    $rate=1     unless($rate);
     if(0&&defined $params->{exchange_yes})
     {  
            
        my $amnt;

        ($amnt,$rate)=$self->calculate_exchange(0,$rate,$params->{currency},$params->{ct_currency});


        $amnt=$params->{ct_amnt}+$params->{ct_ext_commission}+$comis;
        $amnt=$amnt/$rate;
        $result_amnt=$amnt;
        $eid=$self->add_exc(
        {
            e_date=>$params->{ct_ts},
            a_id=>$params->{ct_aid},
            e_currency1=>$params->{currency},
            e_currency2=>$params->{ct_currency},
            rate=>$params->{rate},
            type=>'auto',
            e_amnt1=>$amnt,
            e_comment=>'��������� ��� �������������� ������� �� ����� '.$params->{rate}
        });

    
     }      
    $comis*=-1;

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
	0,
	$params->{ct_ts2},
	$params->{ct_ext_commission},
	0,
    $params->{ct_aid},$per,$params->{ct_id});	
	
	}else{
		$dbh->do(qq[UPDATE
	 	cashier_transactions SET
	 	ct_ts=NOW(),ct_comment=?,
	  	ct_oid2=?,		
		ct_status='processed',ct_tid2=?,ct_fid=?,ct_fsid=?,
	  	ct_tid2_comis=?,ct_date=NOW(),ct_ts2=?,
		ct_ext_commission=?,ct_tid2_ext_com=?,ct_aid=?,
		ct_comis_percent=?,ct_eid=$eid,ct_req='no' 
		WHERE ct_id=?],
	    undef,
        	$params->{ct_comment},$self->{user_id},
	    $tid,
	    $params->{ct_fid},
    	    $params->{ct_fsid},
	    0,
	    $params->{ct_ts2},
	    $params->{ct_ext_commission},
	    0,$params->{ct_aid},$per,$params->{ct_id});	
	

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
	 0 AS `comission`,
         `cashier_transactions`.`ct_amnt` AS `result_amnt`,
	`cashier_transactions`.`ct_comis_percent` AS `ct_comis_percent`,
	0 AS `ct_ext_commission`,
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
    left join out_firms  on (`cashier_transactions`.`ct_ofid` = out_firms.`of_id`)) 
 	where ((`cashier_transactions`.`ct_amnt` < 0) 
	and (`cashier_transactions`.`ct_status` in (_cp1251'processed'))) 
	AND ct_id=? LIMIT 1],undef,$params->{ct_id});	




	
	unless($params->{non_redirect})
	{
    		$self->header_type('redirect');
    		return $self->header_add(-url=>'?#'.$params->{ct_id});
	}else
	{
		return 1;
	}


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
	$params->{ct_aid}=$dbh->selectrow_array('SELECT a_id FROM accounts WHERE a_id=?',undef,$ct_aid);
	$params->{ct_fsid}=$ct_fsid;
	$params->{ct_comis_percent}=$self->query->param('ct_comis_percent');

	$params->{ct_ts2}=$self->query->param('ct_ts2');
	
    $params->{ct_comis_percent_exchange}=$self->query->param('ct_comis_percent_exchange');

    $params->{ct_comis_percent_in_exchange}=$self->query->param('ct_comis_percent_in_exchange');

    $params->{ct_ext_commission_perc}=$self->query->param('ct_comis_percent_in');

	$params->{ct_comis_percent_exchange}=~s/,/\./g;

	$params->{ct_comis_percent}=1*$params->{ct_comis_percent};

	return	error_process $self, "�� �� ������� �������� \n " unless($params->{ct_aid});

	$params->{ct_ext_commission}=$ct_ext_comission*1;

    die "������� �������� ������� �������\n" if(abs($params->{ct_comis_percent_exchange})>2*$ETALON_VALUE_COMIS||abs($params->{ct_comis_percent})>2*$ETALON_VALUE_COMIS);


	if($exchange_yes)
	{
		return 	error_process $self, "�� ����� ���� ������ \n"	unless($light_rate);
		return 	error_process $self, "�� ������ ������ ������ \n" unless($avail_currency->{$source_currency});

		my $currencies=$dbh->selectrow_array(q[SELECT 
		ct_currency FROM cashier_transactions 
		WHERE ct_id=?],undef,$ct_id[int(rand(scalar(@ct_id)))]);
		die "�������� ������ ������ \n" if($source_currency eq $currencies);
		
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
    my_log($self,$TIMER->stop);
	$self->header_type('redirect');
	return $self->header_add(-url=>'?');


	
	
	
}




1;
