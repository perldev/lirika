package Oper::FirmInput2;

use strict;

use base 'CGIBase';

use SiteConfig;
use SiteDB;
use SiteCommon;
use Documents;
my $proto;

sub get_right
{       
        my $self=shift;

   
    $proto={
    'table'=>"cashier_transactions",  
    'template_prefix'=>"firm_in2",
    'page_title'=>'Выписки',
    'extra_where'=>q[ ct_amnt>0 AND ct_fid>0 AND ct_status!='deleted' ],
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
                        ct_comis_income
                        var ct_comis_income=get_element('ct_comis_income',1);
                        set_element('ct_comis_income',ct_comis_income);
					    set_element('ct_comis_percent',commission_percent);
                        commission_percent=commission_percent*1+1*ct_comis_income;
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
        , "type"=>"select",'or_obj'=>0
        },
#         {
#             'field'=>"ct_ofid",
#              alias=>'out_firm',
#             "title"=>"Фирма клиента", 
#              select_search=>1,
#              type=>'select',
#              no_add_edit=>1,
#              category=>'out_firms',
#              filter=>'=',
#              titles=>&get_out_firms(1),'or_obj'=>1
#         },
#         {
#               'field'=>"ct_ofid","title"=>"ОКПО", 
#               select_search=>1,
#               type=>'select',
#               filter=>'=',
#               no_add_edit=>1,
#               category=>'out_firms_okpo',
#               titles=>&get_out_firms_okpo(1),
#              'or_obj'=>1
#         },
#       
        {
             'field'=>"ct_aid", "title"=>"Карточка", 
             select_search=>1,
             type=>'select','or_obj'=>1,filter=>'=',
            'titles'=>&get_accounts_simple(),category=>'accounts'
	    },
    
        {
	    'field'=>"ct_fsid", "title"=>"Услуга", "category"=>"firm_services", "may_null"=>1,
            java_script_action=>'onchange="change_services()"'
        },
        {'field'=>"ct_amnt", "title"=>"Сумма", "no_add_edit"=>1, 'filter'=>"eq",},

    
#         {'field'=>"ct_comis_income", "title"=>"Комиссия в приходную% ",java_script_action=>'onkeyUp="change_commission()"',
#             no_base=>0 ,},

        {'field'=>"ct_comis_percent", 
        "title"=>"Комиссия% ",java_script_action=>'onkeyUp="change_commission()"',            
            no_base=>0 },
        {'field'=>"commission", "title"=>"Сумма комиссии ",'default'=>"0",'system'=>1,"no_add_edit"=>1,no_base=>1},
        {'field'=>"common_sum", "title"=>"Общая сумма",'default'=>"0",'system'=>1,"no_add_edit"=>1,no_base=>1},	
        {'field'=>"ct_currency", "title"=>"Валюта", 'filter'=>"=", "type"=>"select"
        , "titles"=>\@currencies
        , "no_add_edit"=>1,},
        {'field'=>"ct_eid",'title'=>'Произвести обмен','system'=>1,"category"=>"exchange",'value'=>'ct'},	
    
        {'field'=>"ct_comment", "title"=>"Назначение", "no_add_edit"=>0,'filter'=>'like','or_obj'=>1},
    
        {'field'=>"ct_oid", "title"=>"Оператор"
        , "no_add_edit"=>1, "category"=>"operators"
        },
       
        #{'field'=>"ct_tid", "title"=>"Транзакция", "no_add_edit"=>1,},
    
    
        {
        'field'=>"ct_status", "title"=>"Статус проведения"
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
         {'field'=>"ct_tid2_ext_com", "title"=>"Транзакция 3, в приходную комиссия"
        , "no_add_edit"=>1
        ,"no_view"=>1
        },
        {'field'=>"ct_ext_commission", "title"=>"Дополнительная"
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
 #$SIG{__DIE__}=\&proto_die_catcher;   
  $self->start_mode('list');
$self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'add'  => 'add',
    'edit' => 'edit',
    'del'  => 'del',
    'add_common'=>'add_common',
    'add_common_confirm'=>'add_common_confirm',
    'add_common_do'=>'add_common_do',
  );
}

sub list
{
   my $self = shift;
    
        $proto->{fields}->[7]->{type}='select';
        $proto->{fields}->[7]->{titles}=get_services();

   return $self->proto_list_short($proto);
}

sub add
{

   my $self = shift;
   return $self->proto_add_edit('add', $proto);
	

}

sub add_common
{
	my $self=shift;
	return $self->add_common_();
	


}
sub add_common_confirm
{
	my $self=shift;
	return $self->add_common_confirm_();
}


sub edit
{

   my $self = shift;
   my $param=$self->query->param('action');
   my $confirm=$self->query->param('__confirm');
   my %params;
   map{ $params{$_}=$self->query->param($_) }  $self->query->param();
   $proto->{fields}->[5]->{no_view}='1';

   delete $proto->{fields}->[6]->{'type'};
   delete $params{'apply'};
   delete $params{'do'};
   delete $params{'__confirm'};	
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
   $proto->{fields}->[9]->{no_add_edit}=1;

  if($params->{step} eq 'before'){
   my $tid = "NULL";
   my $tid_comis = "NULL";
   my $tid_in=' NULL';
   my $eid=undef;
   my $aid = $self->query->param('ct_aid');
   my $fsid = $self->query->param('ct_fsid');
##exchange of 
   my $per;
   my ($per_exchange,$per_exchange_in)=(0,0);
   my $in_comis=0;
   my $main_comis=0;
   my $exchange_yes = $self->query->param('exchange_yes');
   my $real_rate=0;
    
   my $id = $self->query->param('id');


    my $ra  = $dbh->selectrow_hashref("SELECT * FROM accounts WHERE  a_id = ".sql_val( $aid ));
    my $per_income = $self->query->param('ct_comis_income');

    if(!get_account_name($ra->{a_incom_id})->{ac_id}&&$per_income>0){
        die "Приходная программа не установлена \n";
    }
	my $currencies=$dbh->selectrow_array(q[SELECT 
			ct_currency FROM cashier_transactions 
			WHERE ct_id=?],undef,$id);
	
	die "Выберите разные валюты \n" if($exchange_yes&&$self->query->param('currency') eq $currencies);
	
##protections from double clicking
	my $protection=$dbh->do(q[UPDATE cashier_transactions 
			                    SET ct_status='processing'
   		      	                WHERE ct_id=? AND ct_status='created' 
			 ],undef,$id); 
	if($protection ne '1')
	{
		
		if($params->{non_redirect})
		{
			##!! only for using in common identification
			return 0;
		}else{
			$self->header_type('redirect');
			return $self->header_add(-url=>'?#'.$params->{ct_id});
		}
	}
   

	my $r = $dbh->selectrow_hashref(q[SELECT * FROM 
        cashier_transactions WHERE ct_status='processing' AND ct_id=?],undef,$id);
	
	





      my $amnt = $r->{'ct_amnt'};
      my $currency = $r->{'ct_currency'};

      my $comment =undef;# $self->query->param('ct_comment'); 
      $comment=$r->{ct_comment}	unless($comment);
      my $fid = $r->{'ct_fid'};     

	
	      
	  my $rfs;     
	  $rfs = $dbh->selectrow_hashref("SELECT * FROM firm_services,client_services WHERE cs_aid=? AND
	  		       fs_id=cs_fsid AND cs_fsid=".sql_val( $fsid ),undef,$aid) if($fsid);
			       
	    my $rf = $dbh->selectrow_hashref("SELECT * FROM firms WHERE f_id = ".sql_val( $fid ));
	     $per = $self->query->param('ct_comis_percent')+0;
	   
	    $per_exchange = $self->query->param('ct_comis_percent_exchange')+0;
        $per_exchange_in = $self->query->param('ct_comis_percent_in_exchange')+0;
        
		$per_exchange=~s/,/\./g;
	    $per=1*($per);
        
        

	 

     $tid = $self->add_trans({
      		t_name1 => $firms_id,
    		t_name2 => $aid,
      		t_currency => $currency,
      		t_amnt => $amnt,
      		t_comment => $comment,
     
      });

  
    $real_rate=$self->calculate_exchange(0,$self->query->param('rate'),$currency,$self->query->param('currency')) if($exchange_yes);

    if(0&&$per_exchange_in>0){
          $in_comis+=($amnt*$real_rate-$amnt*($real_rate-($real_rate/100)*$per_exchange_in))/$real_rate;
    }
    if($per_income>0&&0){
          $in_comis+=$per_income*($amnt/100);

        
    }
  

   
    if($per_exchange>0||$per_exchange<0){
            $main_comis+=($amnt*$real_rate-$amnt*($real_rate-($real_rate/100)*$per_exchange))/$real_rate;
    }
    if($per > 0||$per<0){
            $main_comis+=$per*($amnt/100);
    }
    my $result_amnt=$amnt-$main_comis-$in_comis;
    
    if(0&&($main_comis > 0||$main_comis <0)){
                #  die "$comis_aid,$aid";
                $per+=$per_exchange;
                $tid_comis = $self->add_trans({
                        t_name1 => $aid,
                        t_name2 => $comis_aid,
                        t_currency => $currency,
                        t_amnt => $main_comis,
                        t_comment => "Комиссия $per\% за услугу $rfs->{fs_name}
                        (id#$rfs->{fs_id}) при вводе безнала через фирму $rf->{f_name}(id#$fid), $comment",
            });
    }
     if(0&&$in_comis>0){

             $per_income+=$per_exchange_in;

             $tid_in = $self->add_trans({
                        t_name1 => $aid,
                        t_name2 => $ra->{a_incom_id},
                        t_currency => $currency,
                        t_amnt =>$in_comis,
                        t_comment => "Комиссия $per_income\% за документы
                        (id#$rfs->{fs_id}) при вводе безнала через фирму $rf->{f_name}(id#$fid), $comment",
            });   
    }
    
    if(0&&$exchange_yes)
    {

           $eid=$self->add_exc({
            e_date=>$r->{ct_date},
            a_id=>$aid,
            e_currency1=>$currency,
            e_currency2=>$self->query->param('currency'),
            rate=>$self->query->param('rate'),
            type=>'auto',
            e_amnt1=>$amnt-$main_comis-$in_comis,
            e_comment=>'Автообмен при индентификации прихода по курсу '.$self->query->param('rate')
            });
        $result_amnt*=$real_rate;
        $dbh->do(q[UPDATE cashier_transactions SET ct_eid=? WHERE ct_id=?],undef,$eid,$id);

    }else{

        $eid='NULL';
    }
        
    #$real_rate=$self->query->param('rate');

    $self->query->param('result_amnt',$result_amnt);

#     $self->query->param('calc_main_comis',-1*$main_comis);
    
    $real_rate=1    unless($real_rate);

    $self->query->param('calc_reql_rate',$real_rate);




	##if we are working with request for money and also we need t remember that we work with 
	## positive sums 	
	## because of it we need to update the the account of firm
	if($r->{ct_req} eq 'yes'){

		my $currency=lc($r->{ct_currency});
		$dbh->do("UPDATE firms  SET f_$currency=f_$currency+?  WHERE f_id=?",
					          undef,abs($r->{ct_amnt}),$r->{ct_fid});	
		$dbh->do(q[UPDATE cashier_transactions SET ct_date=NOW(),ct_req='no' WHERE ct_id=?],undef,$id);		
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
     }elsif($row->{field} eq 'ct_comis_percent'){

     	$row->{expr}=$per;
	    $row->{no_add_edit}=1;

     }elsif($row->{field} eq 'ct_tid2_ext_com'){

        $row->{expr}=$tid_in;
        $row->{no_add_edit}=1;

     }elsif($row->{field} eq 'ct_ext_commission'){
        $row->{expr}=$in_comis;
        $row->{no_add_edit}=1;
     }    	
   }
	

   return 1;
  }elsif($params->{step} eq 'operation'){

    my $id=$self->query->param('id');
  
    my $calc_main_comis=$self->query->param('calc_main_comis');
    my $real_rate=$self->query->param('calc_reql_rate');
    my $result_amnt=$self->query->param('result_amnt');

 
    $dbh->do($params->{sql});

	unless($dbh->selectrow_array(q[SELECT ct_id FROM accounts_reports_table WHERE ct_id=? AND ct_ex_comis_type='input'],undef,$id))
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
	    $calc_main_comis  AS `comission`,
        $result_amnt AS `result_amnt`,
	    `cashier_transactions`.`ct_comis_percent` AS `ct_comis_percent`,
	    -1*`cashier_transactions`.`ct_ext_commission` AS `ct_ext_commission`,
        cast(if(isnull(`cashier_transactions`.`ct_ts2`),
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


	    where (1  AND ct_id=? 
                  AND (`cashier_transactions`.`ct_amnt` > 0) 
                  AND (`cashier_transactions`.`ct_status` IN 
                  (_cp1251'processed'))) LIMIT 1],undef,$id);	
	}

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

	die "Вы не выбрали карточку \n " unless($dbh->selectrow_array('SELECT a_id FROM accounts WHERE a_id=?',undef,$ct_aid));
    
    die "Процент комиссии слишком большой\n" if(abs($per_exch)>2*$ETALON_VALUE_COMIS||abs($per)>2*$ETALON_VALUE_COMIS||abs($per_in)>2*$ETALON_VALUE_COMIS||abs($per_exch_in)>2*$ETALON_VALUE_COMIS);
	


	if($exchange_yes)
	{
	
			
			die "Не задан курс обмена \n"	unless($light_rate);
			die "Не задана валюта обмена \n" unless($avail_currency->{$source_currency});
			my $currencies=$dbh->selectrow_array(q[SELECT 
			ct_currency FROM cashier_transactions 
			WHERE ct_id=?],undef,$ct_id[int(rand(scalar(@ct_id)))]);
			die "Выберите разные валюты \n" if($source_currency eq $currencies);
			
	}
	
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
		0,$per,$ct_ts2,$_);
		
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
		`cashier_transactions`.`ct_currency` AS `ct_currency`,
		0 AS `comission`,
		`cashier_transactions`.`ct_amnt`  AS `result_amnt`,
		0 AS `ct_comis_percent`,
		0 AS `ct_ext_commission`,cast(if(isnull(`cashier_transactions`.`ct_ts2`),
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

	$self->header_type('redirect');
	return $self->header_add(-url=>'?');
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
