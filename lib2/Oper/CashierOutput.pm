package Oper::CashierOutput;

use strict;

use base 'CGIBase';

use SiteConfig;
use SiteDB;
use SiteCommon;

my $proto;
#$SIG{__DIE__}=\&handle_errors;

sub get_right
{       
     my $self=shift;

    
     $proto={
        'table'=>"cashier_transactions_comis",  
        'page_title'=>'Заявки на вывод наличных',
        'template_prefix'=>"cashier_out",
        'extra_where'=>"ct_amnt < 0 AND ct_fid=-1 AND ct_status='created'",
        'extra_where2'=>"ct_amnt < 0 AND ct_fid=-1 AND ct_status<>'created'", #for second table (@rows2)
        'sort'=>'ct_date DESC,ct_oid ',
        'need_confirmation'=>1,
        'init_java_script'=>q[
		        var REQ;
		        var READY_STATE_COMPLETE=4;
		        var services_percents=new Array();
		        var start_;
        
                change_comission();
        
        
                if(document.getElementById('__confirm'))
                {
                    
                    var my_table1=document.getElementById('add_form_table').insertRow(5);
        
                    my_table1.className='table_gborders';
        
                    var y1=my_table1.insertCell(0);
                    y1.className='table_gborders';
        
                    var z1=my_table1.insertCell(1);
                    y1.innerHTML="Клиент :";
                    z1.innerHTML="Подробности :";   
                    
                    z1.className='table_gborders';
                    
                            
        
                    var my_table=document.getElementById('add_form_table').insertRow(5);
                    my_table.className='table_gborders';
                    var y=my_table.insertCell(0);
                    y.className='table_gborders';
        
                    var z=my_table.insertCell(1);
                    z.className='table_gborders';
                    y.innerHTML="";
                    z.innerHTML="Поиск похожих сумм...";
            
                    var amnt=get_element('ct_amnt');
                    var ct_comment=get_element('ct_comment');
                    var ct_aid=get_element('ct_aid');
        
                    SendRequest('ajax.cgi','do=search_amnt&search_account='+ct_aid+'&ct_amnt='+amnt+'&ct_comment='+ct_comment,'POST',getReq );
                
                }
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
            
                function SendRequest(url,params,HttpMethod,program)
		        {
			        if(!HttpMethod)
				        HttpMethod='POST';
			        
			        REQ=getHttp();
			        if(REQ)
			        {
				        REQ.onreadystatechange=program;
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
        
			        }
		        
		        }
                function getReq_services(){
                    var ready=REQ.readyState;
                    var data=null;
                    if(ready==READY_STATE_COMPLETE)
                    {
                        data=REQ.responseText;
                        fill_array_services(data);
                        //very important thing there 
                        change_services();
                        
                        start_=0;
                    }
                
                }
        
		        function fill_array(data)
		        {
			        
				        if(window.ActiveXObject)
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
				        var records=x.getElementsByTagName("record");
				        var accounts=x.getElementsByTagName("user");
				        
        
        
				        for(var i=0;i<accounts.length;i++)
				        {
					        
										        
					        
					        
					        
					        var my_table=document.getElementById('add_form_table').insertRow(7);
					        my_table.className='table_gborders';
					        var y=my_table.insertCell(0);
					        y.className='table_gborders';
        
					        var z=my_table.insertCell(1);
					        z.className='table_gborders';
					        y.innerHTML=accounts[i].childNodes[0].nodeValue;
					        z.innerHTML=records[i].childNodes[0].nodeValue;
					        
					        
					        
				        }
				        if(accounts.length==0){
					        var my_table=document.getElementById('add_form_table').insertRow(7);
					        my_table.className='table_gborders';
					        var y=my_table.insertCell(0);
					        y.className='table_gborders';
        
					        var z=my_table.insertCell(1);
					        z.className='table_gborders';
					        y.innerHTML="";
					        z.innerHTML=" Совпадений за предыдущие 14 дней не найдено";
					        
        
				        }
			        
        
        
        
        
		        }
	            function fill_array_services(data)
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
                        return 0;
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
                function change_services(){
                
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
                            //set_element('common_sum',0);
                            return ;
                    }else if(!selected_service)
                    {
                        change_comission();
                    }
                
                    var user_status;
                    var val=search_if_exist(id_val,selected_service);
        	    
                    if(!val&&val!=0)
                    {
                        start_=1;
        
                        SendRequest("ajax.cgi","do=get_account_services_percent&service="+selected_service,'POST',getReq_services);
                        
                    }else
                    {   
                            
                            change_comission(val);
                        
                    }
                }
                function change_common_sum(event)
                {
        
                        if(event&&event.keyCode==9)
                            return;
                        
                        var percent=get_element('ct_comis_percent',1);
                        var percent1=get_element('ct_comis_percent_ex',1);

		                var common_sum=get_element('common_sum',1);
                        if(!percent)
                        {
                            set_element('ct_amnt',common_sum);
                            return;
        
                        }
                            
        
        //              var common_sum=get_element('common_sum',1);
        
        
                        var k=(100-(percent+percent1))/(percent+percent1);
                        
                                
                        set_element('commission_in',percent1*(common_sum/(1-percent1/100)/100));

                        set_element('commission',percent*(common_sum/(1-percent/100)/100));
        
                        set_element('ct_amnt',common_sum-common_sum/k);
                    
                                
        
        
                }
                
        
        
        
                function change_comission(val,event)
                {
                        
                        if(event&&event.keyCode==9)
                            return;
    			
                        if(val)    
                            set_element('ct_comis_percent',val);

                        var percent=get_element('ct_comis_percent',1);
                        var percent1=get_element('ct_comis_percent_ex',1);

                    
			            var c=get_element('ct_amnt',1);
                        //document.getElementById('ct_amnt').value;
                        
                        set_element('commission',percent*(c/(1-percent/100)/100));
                        set_element('commission_in',percent1*(c/(1-percent1/100)/100));

                        percent=1*percent1+1*percent;
                        set_element('common_sum',1*c+1*((percent)*(c/(1-percent/100)/100)));
        
                }
        
	        
	        ],
        
        'sort'=>'ct_date DESC,ct_oid',
        'fields'=>[
            {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1,filter=>'=','filter_invisible'=>'1'},    
            {'field'=>"ct_date","title"=>"Дата", 'filter'=>"time","category"=>'date'},
            {'field'=>"ct_ts", "no_add_edit"=>1, "add_expr"=>"NOW()", no_view=>1},
            {'field'=>"ct_req","no_add_edit"=>1,"add_expr"=>"'yes'", no_view=>1},
            {'field'=>"ct_aid", "title"=>"Карточка", "category"=>"accounts",
	        'type'=>'select',
	        'filter'=>'='
	        },
            {
                'field'=>"ct_amnt", "title"=>"Сумма", "op"=>"-", 
                'filter'=>"=",
                "positive"=>1,
                java_script_action=>'onkeyUp="change_comission(0,event)"',
            },
            {
            'field'=>"ct_currency", "title"=>"Валюта"
            , "type"=>"select"
            , "titles"=>\@currencies
            , 'filter'=>"=",
	        'req_currency'=>1,
            },
            {
              'field'=>"ct_fsid", "title"=>"Услуга", "category"=>"kassa_firm_services",type=>'select',"may_null"=>1,
                java_script_action=>'onchange="change_services()"'
            },
            { 
                'field'=>"ct_comis_percent_ex",
                "title"=>"Комиссия% в приходную ",
                java_script_action=>'onkeyUp="change_comission(0,event)"',            
               
            },
            {
                'field'=>"commission_in", 
                "title"=>"Сумма комиссии в приходную",
                'system'=>1,"no_add_edit"=>1,no_base=>1,

            },
            
            
            { 
                'field'=>"ct_comis_percent",
                "title"=>"Комиссия% ",
                java_script_action=>'onkeyUp="change_comission(0,event)"',            
                no_base=>0 
            },
            {
                'field'=>"commission", 
                "title"=>"Сумма комиссии ",
                'default'=>"0",'system'=>1,"no_add_edit"=>1,no_base=>1
            },
            {
                'field'=>"common_sum", 
                "title"=>"Сумма к снятию ",
                'default'=>"0",'system'=>1,"no_add_edit"=>1,no_base=>1,
                  java_script_action=>'onkeyUp="change_common_sum(event)"'
            },
        
            {'field'=>"ct_comment", "title"=>"Назначение", 'default'=>"Вывод наличными",filter=>'like','require'=>1},
            {'field'=>"ct_oid", "title"=>"Оператор"
            , "no_add_edit"=>1, "category"=>"operators"
            },
            {'field'=>"ct_tid", "title"=>"Транзакция"
            , "no_add_edit"=>1,
            },
        
            {'field'=>"ct_status", filter=>'=',"title"=>"Статус", "no_add_edit"=>1
            , "type"=>"select"
            , "titles"=>[
                {'value'=>"created", 'title'=>"в процессе"},
                {'value'=>"processed", 'title'=>"выдан"},
                {'value'=>"canceled", 'title'=>"отменен"},
            ]
            },
           
        
        ],
        };

        $proto->{fields}->[4]->{'titles'}=&get_accounts_simple();
        $proto->{active_blocking}=$dbh->selectrow_array(q[SELECT cob_id 
        FROM cashier_out_block WHERE DATE(cob_date)=DATE(current_timestamp) AND cob_block='yes']);

        return 'cash_out';
}

sub setup
{
  my $self = shift;
    
  $self->run_modes(
    'AUTOLOAD' => 'list',
    'list'     => 'list',
    'add'      => 'add',
    'back'     => 'back',
    'add_many'=>'add_many',
    'add_many_confirm'=>'add_many_confirm',
    'add_many_do'=>'add_many_do',
  );
}
sub add
{
   my $self = shift;
    $proto->{'page_title'}='Вывод наличных';
    ##delete keys for field ct_aid for normal working search field  
    delete $proto->{fields}->[4]->{filter};
    delete $proto->{fields}->[4]->{type};
    delete $proto->{fields}->[4]->{titles};
 
    my $ct_amnt=$self->query->param('ct_amnt');
   
    if($ct_amnt){
            my $a=get_account_name($self->query->param('ct_aid'));

      
            my $currency=$self->query->param('ct_currency');
            $ct_amnt=~s/[ ]//g;
            $ct_amnt=~s/[,]/\./g;
            delete $proto->{fields}->[8]->{java_script_action};
            delete $proto->{fields}->[12]->{java_script_action};
            
            $self->query->param('ct_amnt',$ct_amnt);
            $self->{tpl_vars}->{error_msg}='';  
            $self->{tpl_vars}->{error_msg}="Баланс данной карточки уйдет в минус \n" if($a->{ac_id}==$CLIENT_CATEGORY&&($a->{lc($currency)}-$ct_amnt)<0);
             $self->{tpl_vars}->{error_msg}.="Вы точно уверены что хотите выдать доллары \n"   if(lc($currency) eq 'usd');
     
    }
    if($self->query->param('action') eq 'apply'&&$self->query->param('__confirm')){
                    $proto->{fields}->[8]->{no_add_edit}=1;
                    $proto->{fields}->[8]->{'system'}=1;
                    $proto->{fields}->[8]->{'no_base'}=1;
                    my $per=$self->query->param('ct_comis_percent_ex');
                    my $ct_amnt=$self->query->param('ct_amnt');
                    $self->query->param('ct_ext_commission',$per*($ct_amnt/(1-$per/100)/100));
                    push @{ $proto->{fields}  },{field=>'ct_ext_commission'};
                 
    }
    $proto->{'table'}="cashier_transactions";

   
   return $self->proto_add_edit('add', $proto);
}

sub   add_many
{
	my $self=shift;
	my $tmpl=$self->load_tmpl('cashier_output_many.html');
	my $output='';

    $self->{tpl_vars}->{services}=&get_cash_services;
	$self->{tpl_vars}->{page_title}='Добавление заявок на расход';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;
}

sub add_many_confirm
{
	my $self=shift;
	my $tmpl=$self->load_tmpl('cashier_output_many_confirm.html');
	

	my %params;
	my %keys=$self->query->param();
	map{$keys{$_}=1; }values %keys;
	#deleting unneeded keys
	my @ct_aid=('ct_aid1','ct_aid2','ct_aid3','ct_aid4','ct_aid5');
	map {delete $keys{$_} } @ct_aid; 	
	delete $keys{'do'};
	delete $keys{'__submit'};
	##

	map{ my @ar=$self->query->param($_);$params{$_}=\@ar; } keys %keys;
	map{ $params{$_}=$self->query->param($_);$params{$_.'name'}=$dbh->selectrow_array(q[SELECT a_name FROM accounts WHERE a_id=?],undef,$params{$_}) } @ct_aid;

	my $i;
	my $size=@ct_aid;
	my $size2=0;
	my @global_array;
    my $tmp_amnt;
    my $is_dollar;
	for($i=1;$i<=$size;$i++){
		if(defined $params{"ct_aid$i".'name'})
		{
	
		push @global_array,{name=>1,field_name=>"ct_aid$i",a_id=>$params{"ct_aid$i"},a_name=>$params{"ct_aid$i".'name'} };
			$size2=@{ $params{"ct_amnt$i"} };
            return $self->error("У вас нет прав на выдачу денег с этой программы \n")    unless($self->cashier_out_perms($params{"ct_aid$i"}));

            


            my $ct_amnt={uah=>0,usd=>0,eur=>0};
            my $a=get_account_name($params{"ct_aid$i"});
            $is_dollar=0;
			for(my $j=0;$j<$size2;$j++){

                $tmp_amnt=format_float_inner($params{"ct_amnt$i"}->[$j]);

                $is_dollar=1   if(lc($params{"ct_currency$i"}->[$j]) eq 'usd');

                $ct_amnt->{lc($conv_currency->{$params{"ct_currency$i"}->[$j]})}+=$tmp_amnt;
    				push @global_array,{    
                                        amnt=>format_float($params{"ct_amnt$i"}->[$j]),
							            field_name=>"$i",
							            ct_amnt=>$tmp_amnt,
							            comment=>$params{"ct_comment$i"}->[$j],
							            currency=>$conv_currency->{$params{"ct_currency$i"}->[$j]},
							            ct_currency=>$params{"ct_currency$i"}->[$j],
                                        ct_date=>$params{"ct_date$i"}->[0],
                                        ct_common_amnt=>$params{"ct_common_amnt$i"}->[$j],
                                        ct_comis=>$params{"ct_comis$i"}->[$j]
						    } if($params{"ct_amnt$i"}->[$j]!=0&&trim($params{"ct_comment$i"}->[$j])&&$conv_currency->{$params{"ct_currency$i"}->[$j]});
                           
                

			}
            push @global_array,{error_msg=>"Баланс  карточки в UAH $a->{account_title}  уйдет в минус \n"} if($a->{ac_id}==$CLIENT_CATEGORY&&$ct_amnt->{uah}&&($a->{uah}-$ct_amnt->{uah})<0);
            push @global_array,{error_msg=>"Баланс  карточки в USD $a->{account_title}  уйдет в минус \n"} if($a->{ac_id}==$CLIENT_CATEGORY&&$ct_amnt->{usd}&&($a->{usd}-$ct_amnt->{usd})<0);
            push @global_array,{error_msg=>"Баланс  карточки в EUR $a->{account_title}  уйдет в минус \n"} if($a->{ac_id}==$CLIENT_CATEGORY&&$ct_amnt->{eur}&&($a->{eur}-$ct_amnt->{eur})<0);

            push @global_array,{error_msg=>"Вы уверены что хотите выдать доллары из $a->{account_title} \n"} if($is_dollar);
        

		
		}	
	}
	$self->{tpl_vars}->{requests}=\@global_array;
	my $output='';

	$self->{tpl_vars}->{page_title}='Подтверждение  заявок на расход';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();

	return $output;
}
sub add_many_do
{
	my $self=shift;
	
	
	my %params;
	my %keys=$self->query->param();
	map{$keys{$_}=1; } values %keys;
	#deleting unneeded keys
	my @ct_aid=('ct_aid1','ct_aid2','ct_aid3','ct_aid4','ct_aid5','ct_date1','ct_date2','ct_date3','ct_date4','ct_date5');
	map {delete $keys{$_} } @ct_aid; 	
	delete $keys{'do'};
	delete $keys{'__submit'};
	##
	map{ my @ar=$self->query->param($_);$params{$_}=\@ar; } keys %keys;
	map{ $params{$_}=$self->query->param($_);$params{$_.'name'}=$dbh->selectrow_array(q[SELECT a_name FROM accounts WHERE a_id=?],undef,$params{$_}) } @ct_aid;
	my $i;
	my $size=@ct_aid;
	my $size2=0;
	my $ct_aid=undef;
	my $ct_currency;
	my $ct_comment;
	my $ct_amnt;
    my $ct_comis;
    my $ct_date;
	my $ct_oid=$self->{user_id};
	my $sql=qq[INSERT $SQL_DELAYED INTO  
	cashier_transactions(ct_fid,ct_aid,ct_currency,ct_amnt,ct_comis_percent,ct_comment,ct_oid,ct_ts,ct_date) VALUES];

    
    
	for($i=1;$i<=$size;$i++){

		if(defined $params{"ct_aid$i".'name'})
		{
			$ct_aid=$params{"ct_aid$i"};
            return $self->error("У вас нет прав на выдачу денег с этой программы \n") unless($self->cashier_out_perms($ct_aid));


             my $o=$dbh->selectrow_array(q[SELECT cob_id FROM cashier_out_block 
             WHERE cob_block='yes' AND DATE(cob_date)=?],undef,$self->query->param('ct_date'));
              my $o=$dbh->selectrow_array(q[SELECT cob_id 
                                            FROM cashier_out_block 
                                            WHERE 
                                            cob_block='yes' 
                                            AND (
                                            DATE(cob_date)=? OR DATE(cob_date)>?
                                            )
                                            ],undef,$params{"ct_date$i"},$params{"ct_date$i"});
                    
            if(!$o){
            
                $ct_date=$params{"ct_date$i"};
                $ct_date="'$ct_date'";
            }else{
                $ct_date='DATE_ADD(NOW(),interval 1 day)';
            }
            


			$size2=@{ $params{"ct_amnt$i"} };
			for(my $j=0;$j<$size2;$j++)
			{
				if($params{"ct_amnt$i"}->[$j]!=0&&
				trim($params{"ct_comment$i"}->[$j])&&
				$conv_currency->{$params{"ct_currency$i"}->[$j]}){

					$ct_currency=format_string_inner_sql($params{"ct_currency$i"}->[$j]);
					$ct_amnt=-1 * abs(format_float_inner($params{"ct_amnt$i"}->[$j]));
                    $ct_comis=abs(format_float_inner($params{"ct_comis$i"}->[$j]));

					$ct_comment=format_string_inner_sql($params{"ct_comment$i"}->[$j]);
#                     $ct_date=$params{"ct_date$i"};
					$sql.="(-1,$ct_aid,$ct_currency,$ct_amnt,$ct_comis,$ct_comment,$ct_oid,NOW(),$ct_date),";	
				}
				
			}
		
		}	
	}
	chop($sql);
	$dbh->do($sql);
		$self->header_type('redirect');
	return  $self->header_add(-url=>'?');
}
sub cashier_out_perms
{
    my $self=shift;
    my $aid=shift;
    return $dbh->selectrow_array(q[SELECT 
    oaco_id FROM operators_accounts_cashier_out 
    WHERE oaco_aid=? AND oaco_oid=?],undef,$aid,$self->{user_id});
    


}



sub list
{
   my $self = shift;
   $self->get_cash_conclusions($proto);

   return $self->proto_list($proto);
}
sub back
{

	my $self = shift;
	my $id=$self->query->param('ct_id');
	my $ref=$dbh->selectrow_hashref(q[SELECT 
    abs(ct_amnt) as ct_amnt,
    ct_currency,
    ct_aid,
    DATE(current_timestamp) as date,ct_comment,ct_comis_percent,ct_ext_commission
				FROM cashier_transactions WHERE ct_id=? AND ct_status='processed'],undef,$id);

	unless($ref){
			$self->header_type('redirect');
			return	$self->header_add(-url=>'cashier_input.cgi?');
	}
	$proto->{page_title}="Возврат денег ";
	$self->query->param('action','apply');
    $self->query->param('ct_comis_percent',$ref->{ct_comis_percent}*(-1));
    $ref->{ct_ext_commission}=$ref->{ct_ext_commission}*(-1);
    my $const=$ref->{ct_ext_commission}/($ref->{ct_amnt});
    


    $const=int((($const*100)/(1+$const)+$STAND_MIS)*1000)/1000;

    $self->query->param('ct_comis_percent_ex',$const);
    delete $proto->{fields}->[12]->{java_script_action};
	$self->query->param('do','add');
	$self->query->param('ct_date',$ref->{date});
	$self->query->param('ct_amnt',$ref->{ct_amnt});
	$self->query->param('id',$id);

	$self->query->param('ct_currency',$ref->{ct_currency});
	$self->query->param('ct_aid',$ref->{ct_aid});
	$self->query->param('ct_comment',"Возврат денег $id:".$ref->{ct_comment});
	return $self->proto_add_edit('add', $proto);

	
}


sub del{
   	my $self = shift;
	my $ct_id=$self->query->param('ct_id');
	$dbh->do(q[DELETE FROM cashier_transactions WHERE ct_id=? AND ct_status='created'],undef,$ct_id);

	$self->header_type('redirect');
	return	$self->header_add(-url=>'?');


}

##addon


sub proto_add_edit_trigger{
  my $self=shift;
  my $params = shift;
  my $id=$self->query->param('id');
  my $do=$self->query->param('do');
  
   
  if($params->{step} eq 'before'){
   
    die "У вас нет прав на выдачу денег с этой программы \n" unless($self->cashier_out_perms($self->query->param('ct_aid')));

       my $income_card=$dbh->selectrow_array(q[SELECT a.a_id 
        FROM accounts as a 
        WHERE a_id IN 
        (SELECT s.a_incom_id FROM accounts as s WHERE s.a_id=?)],undef,$self->query->param('ct_aid'));

        die "У данной программы не обозначенна в настройках приходная \n"    if(!$income_card&&$self->query->param('ct_ext_commission')>0);


   my $o=$dbh->selectrow_array(q[SELECT cob_id FROM cashier_out_block 
    WHERE cob_block='yes' AND (DATE(cob_date)=? OR DATE(cob_date)>?)  ],undef,$self->query->param('ct_date'),$self->query->param('ct_date'));


   foreach my $row( @{$params->{proto}->{fields}} ){
     if($row->{field} eq 'ct_oid'){
       $row->{expr} = $self->{user_id};
       
     }elsif($row->{field} eq 'ct_ts'){

        $row->{expr}='NOW()';
     }elsif($row->{field} eq 'ct_ext_commission'){
         $row->{expr}=$self->query->param('ct_ext_commission');
     
     }elsif($row->{field} eq 'ct_date')
     {
       
        if($o)
        {
             $row->{expr}='DATE_ADD(NOW(),interval 1 day)';
             $row->{no_add_edit}=1;
        }
  
     }
   
     
   }

   return 1;   

  }elsif($params->{step} eq 'operation'){

    $dbh->do($params->{sql});
	if($do eq 'add'&&defined($id))
	{
		$dbh->do(q[UPDATE accounts_reports_table SET ct_status='returned' WHERE 
		ct_ex_comis_type='input' AND  ct_fid=-1 AND ct_id=?],undef,$id);
	
		$dbh->do(q[UPDATE cashier_transactions SET ct_status='returned' WHERE ct_id=?],undef,$id);
	}
  }

}

sub handle_errors{

       return if $^S; # for eval die
        my $msg=join ',', @_;
        my @arr=split(':',$msg);
        $msg=$arr[1];
        $msg=~s/at(.*)//;
    
        my $tmpl = Template->new(
        {
            INCLUDE_PATH => "../tmpl",
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