package Oper::CashierInputBefore;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $RIGHT='cash_in_before';

my $proto;

sub get_right
{
        my $self=shift;
       

    $proto={
        'table'=>"cashier_transactions", 
        'page_title'=>'Ввод наличных',
        'sort'=>'ct_ts DESC,ct_oid ',
        'extra_where'=>"ct_amnt > 0 AND ct_fid=-1 ",  #AND ct_status='created'
        'template_prefix'=>"cashier_in_before",
        'need_confirmation'=>1,
        
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
					        
										        
					        
					        
					        
					        var my_table=document.getElementById('add_form_table').insertRow(8);
					        my_table.className='table_gborders';
					        var y=my_table.insertCell(0);
					        y.className='table_gborders';
        
					        var z=my_table.insertCell(1);
					        z.className='table_gborders';
					        y.innerHTML=accounts[i].childNodes[0].nodeValue;
					        z.innerHTML=records[i].childNodes[0].nodeValue;
					        
					        
					        
				        }
				        if(accounts.length==0)
				        {
					        var my_table=document.getElementById('add_form_table').insertRow(8);
					        my_table.className='table_gborders';
					        var y=my_table.insertCell(0);
					        y.className='table_gborders';
        
					        var z=my_table.insertCell(1);
					        z.className='table_gborders';
					        y.innerHTML="";
					        z.innerHTML=" Совпадений за предыдущие 14 дней не найдено";
					        
        
				        }
			        
        
        
        
        
		        }
		        if(document.getElementById('__confirm'))
		        {
			        
			        var my_table1=document.getElementById('add_form_table').insertRow(6);
        
			        my_table1.className='table_gborders';
        
			        var y1=my_table1.insertCell(0);
			        y1.className='table_gborders';
        
			        var z1=my_table1.insertCell(1);
			        y1.innerHTML="Клиент :";
			        z1.innerHTML="Подробности :";	
			        
			        z1.className='table_gborders';
			        
					        
        
			        var my_table=document.getElementById('add_form_table').insertRow(6);
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
        
        SendRequest('ajax.cgi','do=search_amnt&search_account='+ct_aid+'&ct_amnt='+amnt+'&ct_comment='+ct_comment,'POST');
		        
		        }
	        
	        ],	
        'fields'=>[
            {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1,filter=>'=','filter_invisible'=>'1'},    
            {'field'=>"ct_date", 'category'=>'date', "title"=>"Дата", 'filter'=>"time"},
            {'field'=>'ct_ts',"no_add_edit"=>1,'no_view'=>1},
            {'field'=>'ct_comis_percent',"no_add_edit"=>1,'no_view'=>1},
        
            {'field'=>'ct_req',"no_add_edit"=>1,,'no_view'=>1,"add_expr"=>"'yes'"},
            {
	        'field'=>"ct_aid", "title"=>"Карточка", "category"=>"accounts",
	        'type'=>'select',
	        'filter'=>'='
        },	
            {'field'=>"ct_amnt", "title"=>"Сумма", 'filter'=>"=", "positive"=>1,java_script_action=>"onkeyup='amnt_pressed()'",
            java_script=>"
                function amnt_pressed()
	            {
	                get_element('ct_amnt',1);
							        
	            }
        "
									        
            },
            {'field'=>"ct_currency", "title"=>"Валюта"
            , "type"=>"select"
            , "titles"=>\@currencies
            , 'filter'=>"=",
	        'req_currency'=>1,
            },
            {'field'=>"ct_comment", "title"=>"Назначение", "default"=>'Ввод наличных','require'=>1,filter=>'like'},
            {'field'=>"ct_oid", "title"=>"Оператор"
            , "no_add_edit"=>1, "category"=>"operators"
            },
            {'field'=>"ct_status",filter=>'=', "title"=>"Статус"
            , "no_add_edit"=>1,'no_view'=>1,
	        "type"=>"select"
            , "titles"=>[
                {'value'=>"created", 'title'=>"в процессе"},
                {'value'=>"processed", 'title'=>"проведен"},
	        {'value'=>"canceled", 'title'=>"отменен"},
            ]
            , 'filter'=>"="
            , "no_add_edit"=>1
            },
        
        ],
        };
        $proto->{fields}->[5]->{'titles'}=&get_accounts_simple();

        return 'cash_in_before';
}

sub setup
{
  my $self = shift;
    
  $self->run_modes(
    	'AUTOLOAD'   => 'list',
    	'list' => 'list',
    	'add'  => 'add',
    	'edit' => 'edit',
    	'del'  => 'del',
	    'back'=>'back',
        'add_many'=>'add_many',
    	'add_many_confirm'=>'add_many_confirm',
    	'add_many_do'=>'add_many_do',
	

  );
}

sub   add_many
{
	my $self=shift;
	my $tmpl=$self->load_tmpl('cashier_input_many.html');
	my $output='';
	$self->{tpl_vars}->{page_title}='Добавление заявок на приход';
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
	for($i=1;$i<=$size;$i++)
	{
		if(defined $params{"ct_aid$i".'name'})
		{
	
		push @global_array,{name=>1,field_name=>"ct_aid$i",a_id=>$params{"ct_aid$i"},a_name=>$params{"ct_aid$i".'name'} };
			$size2=@{ $params{"ct_amnt$i"} };
			for(my $j=0;$j<$size2;$j++)
			{
				push @global_array,{    amnt=>format_float($params{"ct_amnt$i"}->[$j]),
							field_name=>"$i",
							ct_amnt=>format_float_inner($params{"ct_amnt$i"}->[$j]),
							comment=>$params{"ct_comment$i"}->[$j],
							currency=>$conv_currency->{$params{"ct_currency$i"}->[$j]},
							ct_currency=>$params{"ct_currency$i"}->[$j] 
						    } if($params{"ct_amnt$i"}->[$j]!=0&&trim($params{"ct_comment$i"}->[$j])&&$conv_currency->{$params{"ct_currency$i"}->[$j]});
				
			}
		
		}	
	}
	$self->{tpl_vars}->{requests}=\@global_array;
	my $output='';

	$self->{tpl_vars}->{page_title}='Подтверждение  заявок на приход';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();

	return $output;
}
sub add_many_do
{
	my $self=shift;
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
	my $ct_aid=undef;
	my $ct_currency;
	my $ct_comment;
	my $ct_amnt;
	my $ct_oid=$self->{user_id};
	my $sql=qq[INSERT $SQL_DELAYED INTO  
	cashier_transactions(ct_fid,ct_aid,ct_currency,ct_amnt,ct_comment,ct_oid,ct_ts,ct_date) VALUES];

	for($i=1;$i<=$size;$i++)
	{
		if(defined $params{"ct_aid$i".'name'})
		{
			$ct_aid=$params{"ct_aid$i"};
			$size2=@{ $params{"ct_amnt$i"} };
			for(my $j=0;$j<$size2;$j++)
			{
				 if($params{"ct_amnt$i"}->[$j]!=0&&
				trim($params{"ct_comment$i"}->[$j])&&
				$conv_currency->{$params{"ct_currency$i"}->[$j]})
				{
					$ct_currency=format_string_inner_sql($params{"ct_currency$i"}->[$j]);
					$ct_amnt= abs(format_float_inner($params{"ct_amnt$i"}->[$j]));
					$ct_comment=format_string_inner_sql($params{"ct_comment$i"}->[$j]);
					$sql.="(-1,$ct_aid,$ct_currency,$ct_amnt,$ct_comment,$ct_oid,NOW(),NOW()),";	
				}
				
			}
		
		}	
	}
	chop($sql);
	$dbh->do($sql);
		$self->header_type('redirect');
	return  $self->header_add(-url=>'?');
}
sub list
{
   my $self = shift;
    $self->get_cash_conclusions($proto);
    return $self->proto_list($proto);
}


sub back
{
	my $self=shift;
	my $id=$self->query->param('ct_id');
	my $ref=$dbh->selectrow_hashref(q[SELECT abs(ct_amnt) as ct_amnt,ct_currency,ct_aid,DATE(current_timestamp) as date,ct_comment 
				FROM cashier_transactions WHERE ct_id=? AND ct_status='processed'],undef,$id);
	unless($ref)
	{
			$self->header_type('redirect');
			return	$self->header_add(-url=>'cashier_input.cgi?');
	}
	$proto->{page_title}="Возврат денег ";
	
	$self->query->param('action','apply');
	$self->query->param('do','add');
	$self->query->param('ct_date',$ref->{date});
	$self->query->param('ct_amnt',$ref->{ct_amnt});
	$self->query->param('id',$id);

	$self->query->param('ct_currency',$ref->{ct_currency});
	$self->query->param('ct_aid',$ref->{ct_aid});
	$self->query->param('ct_comment',"Возврат денег $id:".$ref->{ct_comment});
	return $self->proto_add_edit('add', $proto);


	
}

sub add
{
   my $self = shift;
	##delete keys for field ct_aid for normal working search field 	

   delete $proto->{fields}->[4]->{filter};
   delete $proto->{fields}->[4]->{type};
   delete $proto->{fields}->[4]->{titles};
   return $self->proto_add_edit('add', $proto);
}

sub edit
{
	my $self = shift;

  	my $id=$self->query->param('id');
	##delete keys for field ct_aid for normal working search field 	

  	delete $proto->{fields}->[4]->{filter};
   	delete $proto->{fields}->[4]->{type};
   	delete $proto->{fields}->[4]->{titles};
	
       $id=$dbh->selectrow_array(
       qq[SELECT ct_id FROM cashier_transactions WHERE ct_status in ('created') AND ct_id=?],
       undef,
       $id);
	unless($id)
	{		
		$self->header_type('redirect');
		return $self->header_add(-url=>'?#'.$id);	
	}else
	{	
		return $self->proto_add_edit('edit', $proto);
	}
}

sub del
{
   my $self = shift;
   my $id=$self->query->param('id');
   $dbh->do(
       qq[DELETE FROM cashier_transactions WHERE ct_status in ('created','canceled') AND ct_id=?],
       undef,
       $id);
   $self->header_type('redirect');
   return $self->header_add(-url=>'?');

}

sub proto_add_edit_trigger{
  my $self=shift;
  my $params = shift;    
  my $id=$self->query->param('id');
  my $do=$self->query->param('do');

    
    
    
  if($params->{step} eq 'before'){
   
    my $percent=0; 
    if($id)
    {
        $percent=$dbh->selectrow_array(q[SELECT ct_comis_percent FROM cashier_transactions 
        WHERE ct_id=? AND ct_fid=-1],undef,$id);
        
    }
    


   foreach my $row( @{$params->{proto}->{fields}} ){
     if($row->{field} eq 'ct_oid'){
       $row->{expr} = $self->{user_id}
     }elsif($row->{field} eq 'ct_ts'){
       $row->{expr} = 'current_timestamp';
     }elsif($row->{field} eq 'ct_date'){
       $row->{expr} = 'NOW()';
     }elsif($row->{field} eq 'ct_comis_percent'){
       $row->{expr} = -1*$percent;
     }
   }

   return 1;   

  }elsif($params->{step} eq 'operation'){
   
	$dbh->do($params->{sql});
		if($do eq 'add'&&defined($id)&&$id ne '')
		{
		
		$dbh->do(q[UPDATE accounts_reports_table SET ct_status='returned' WHERE 
		ct_ex_comis_type='input' AND  ct_fid=-1 AND ct_id=?],undef,$id);
		$dbh->do(q[UPDATE cashier_transactions SET ct_status='returned' WHERE ct_id=?],undef,$id);
				

		}
	
	##if it's adding and 	we have an id not empty id param


	}

}


1;