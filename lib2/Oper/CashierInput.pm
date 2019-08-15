package Oper::CashierInput;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $RIGHT='cash_in';
my $proto;
sub get_right
{
        my $self=shift;
    

    $proto={
        'table'=>"cashier_transactions", 
        'page_title'=>'Подтверждение ввода наличных',
        'sort'=>'ct_date DESC,ct_oid ',
        'id_field'=>'ct_id',
        'extra_where'=>"ct_amnt > 0 AND ct_fid=-1",  #AND ct_status='created'
        'need_confirmation'=>1,
        'template_prefix'=>"cashier_in",
        'fields'=>[
            {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1,filter=>'=','filter_invisible'=>'1'},    
            {'field'=>"ct_date", "no_add_edit"=>1, "title"=>"Дата", 'filter'=>"time"},
            {'field'=>"ct_ts2", "no_add_edit"=>1,'no_view'=>1},
            {'field'=>'ct_tid2_comis',"no_add_edit"=>1},
            {'field'=>'ct_req',"no_add_edit"=>1,,'no_view'=>1,"edit_expr"=>"'no'"},
            {'field'=>"ct_aid", "title"=>"Карточка", "category"=>"accounts",
	        'type'=>'select',
	        'filter'=>'='
	        },
            {'field'=>"ct_amnt",no_add_edit=>1, 
            "title"=>"Сумма",
            'filter'=>"=",
            java_script_action=>"onkeyup='amnt_pressed()'",
            java_script=>"
                function amnt_pressed()
	            {
	            
	                    if(!document.getElementById('ct_aid').value)
		                    {
			                        if(document.getElementById('ct_aid__select').value)
					                        document.getElementById('ct_aid').value=document.getElementById('ct_aid__select').value;
							        
							                }
								        
								        
								        
								            }
								                "
									        
            },
            {'field'=>"ct_currency",no_add_edit=>1, "title"=>"Валюта"
            , "type"=>"select"
            , "titles"=>\@currencies
            , 'filter'=>"="
            },
            {'field'=>"ct_comment", "title"=>"Назначение", "default"=>'Ввод наличных',filter=>'like'},
            {'field'=>"ct_status", "title"=>"Статус проведения"
            , "type"=>"select"
            , "titles"=>[
                {'value'=>"created", 'title'=>"в процессе"},
                {'value'=>"processed", 'title'=>"проведен"},
	        {'value'=>"canceled", 'title'=>"отменена"},
            ]
            , 'filter'=>"="
            , "no_add_edit"=>1
            , "no_view"=>1
            },
            {'field'=>"ct_oid2", "title"=>"Оператор 2"
            , "no_add_edit"=>1, 
            ,"no_view"=>1, "category"=>"operators"
            },
            {'field'=>"ct_oid", "title"=>"Оператор получивший"
            , "no_add_edit"=>1, "category"=>"operators"
            },
            {'field'=>"ct_tid", "title"=>"Транзакция"
            , "no_add_edit"=>1,'no_view'=>1
            },
            {'field'=>"ct_status", "title"=>"Статус"
            , "no_add_edit"=>1, "add_expr"=>"'processed'",'no_view'=>1
            },
        
        ],
        };  
        $proto->{fields}->[5]->{'titles'}=&get_accounts_simple();
        return 'cash_in';
}

sub setup
{
  my $self = shift;
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'edit' => 'edit',
    'del'  => 'del',
    're_proc'=>'re_proc'
  );
}
sub list
{
   my $self = shift;
   $self->get_cash_conclusions($proto);
   return $self->proto_list($proto);

}

sub edit
{
   my $self = shift;
  
   delete $proto->{fields}->[4]->{filter};
   delete $proto->{fields}->[4]->{type};
   delete $proto->{fields}->[4]->{titles};
   return $self->proto_add_edit('edit', $proto);


}
sub del
{
   	my $self = shift;
	my $id=$self->query->param('id');
   	$dbh->do(q[UPDATE cashier_transactions SET ct_status='canceled',ct_oid2=?  WHERE ct_status='created' 
	AND  ct_id=?],undef,$self->{user_id},$id);
	$self->header_type('redirect');
	return $self->header_add(-url=>'?#'.$id);	
}
sub re_proc
{
    my $self = shift;
	my $id=$self->query->param('id');
   	$dbh->do(q[UPDATE cashier_transactions SET ct_status='created',ct_oid2=? 
			WHERE ct_status='canceled' 
	AND  ct_id=?],undef,$self->{user_id},$id);
	$self->header_type('redirect');
	return $self->header_add(-url=>'?#'.$id);	
}

sub proto_add_edit_trigger{
 	my $self=shift;
 	my $params = shift;    
   
	

  if($params->{step} eq 'before'){
	my $id=$self->query->param('id');
  
	my $res=$dbh->do(q[UPDATE cashier_transactions
			SET 	ct_status='processing' 
	WHERE   ct_status='created' AND ct_id=? ],undef,$id);			
  	
	if($res ne '1')
	{
		$self->header_type('redirect');
		return $self->header_add(-url=>'?#'.$id);
	}	

   my $percent=$dbh->selectrow_array(q[SELECT ct_comis_percent 
                            FROM cashier_transactions WHERE ct_id=? AND ct_fid=-1],undef,$id);
 
    my $amnt=$self->query->param('ct_amnt');
    my $sum_percent=0;
    if($percent)
    {
            
           $sum_percent=abs(abs($percent)*(($amnt/(1-abs($percent)/100))/100));
           $self->query->param('ct_comis_percent',$percent);
           $self->query->param('percent',$sum_percent);

    }

    my $tid_comis='NULL';
    my $aid= $self->query->param('ct_aid');
    my $currency=$self->query->param('ct_currency');

    if($percent<0)
    {   
        
            $tid_comis = $self->add_trans({
            t_name1 => $comis_aid,
            t_name2 => $aid,
            t_currency => $currency,
            t_amnt => $sum_percent,
            t_comment =>"Комиссия при вводе нала ",
        });
    
    
    }else
    {
            $tid_comis = $self->add_trans({
            t_name1 =>$aid ,
            t_name2 =>$comis_aid,
            t_currency => $currency,
            t_amnt => $sum_percent,
            t_comment =>"Комиссия при вводе нала ",
        });
        
        

    }    

   my $tid = $self->add_trans({
    t_name1 => $kassa_id,
    t_name2 => $self->query->param('ct_aid'),
    t_currency =>$currency,
    t_amnt => $amnt,
    t_comment => $self->query->param('ct_comment'),
   });

   foreach my $row( @{$params->{proto}->{fields}} ){
     if($row->{field} eq 'ct_oid2'){
       $row->{expr} = $self->{user_id}
     }elsif($row->{field} eq 'ct_tid'){
       $row->{expr} = $tid;
     }elsif($row->{field} eq 'ct_status'){
       $row->{expr} = "'processed'";
       
     }elsif($row->{field} eq 'ct_tid2_comis'){

            $row->{expr} = $tid_comis;

     }elsif($row->{field} eq 'ct_ts2')
     {
     	$row->{expr} = "NOW()";	
     }	
   }

   return 1;   

  }elsif($params->{step} eq 'operation'){

    
    
    
    $dbh->do($params->{sql});
    my $percent=0;
    my $sum_comis=0;
    $percent =$self->query->param('ct_comis_percent') || 0;
    $sum_comis=$self->query->param('percent') || 0;
    $sum_comis=-1*$sum_comis   if($percent>0);
       
    $dbh->do(qq[ 
	INSERT  $SQL_DELAYED INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
	o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
	result_amnt,ct_comis_percent,ct_ext_commission,
	ct_date,
	ct_ex_comis_type,ts,col_ts,col_status,
	ct_status,col_color)
	select `cashier_transactions`.`ct_id` AS `ct_id`,
	`cashier_transactions`.`ct_aid` AS `ct_aid`,
	`cashier_transactions`.`ct_comment` AS `ct_comment`,
	`cashier_transactions`.`ct_oid` AS `ct_oid`,
	`operators`.`o_login` AS `o_login`,
	`firms`.`f_id` AS `ct_fid`,
	`firms`.`f_name` AS `f_name`,
	`cashier_transactions`.`ct_amnt` AS `ct_amnt`,
	`cashier_transactions`.`ct_currency` AS 
	`ct_currency`,
     $sum_comis,
	(`cashier_transactions`.`ct_amnt`+($sum_comis)) AS `result_amnt`,
	`cashier_transactions`.`ct_comis_percent` AS `ct_comis_percent`,
	(-(1) * `cashier_transactions`.`ct_ext_commission`) AS `ct_ext_commission`,
	 cast(if(isnull(`cashier_transactions`.`ct_ts2`),`cashier_transactions`.`ct_ts`,
	`cashier_transactions`.`ct_ts2`) as date) AS `ct_date`,
	`cashier_transactions`.`ct_ex_comis_type` AS `ct_ex_comis_type`,
	 if(isnull(`cashier_transactions`.`ct_ts2`),
	`cashier_transactions`.`ct_ts`,
	`cashier_transactions`.`ct_ts2`) AS `ts`,
	'0000-00-00 00:00:00',
	'no',
	`cashier_transactions`.`ct_status` AS `ct_status`,
	16777215 
	from ((`cashier_transactions` 
	left join `firms` on((`cashier_transactions`.`ct_fid` = `firms`.`f_id`))) 
	left join `operators` on((`cashier_transactions`.`ct_oid` = `operators`.`o_id`)))
	 where 	`cashier_transactions`.`ct_status` 
	in (_cp1251'processed')  AND ct_id=? LIMIT 1
	],undef,$self->query->param('id'));	
    

  }

}


1;