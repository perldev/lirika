package Oper::CashierOutput2;

use strict;
use base 'CGIBase';

use SiteConfig;

use SiteDB;

use SiteCommon;


my $proto;
my $kassa_id=undef;
my $co_id=undef;
sub get_right
{
    my $self=shift;

     my ($kassa_title);
     $co_id=undef;
    ($kassa_id,$kassa_title,$co_id)=$dbh->selectrow_array(q[SELECT co_aid,co_title,co_id
                                                            FROM cash_offices 
                                                            WHERE co_name=?],undef,$self->{cash});    

    return 'denied'    unless($kassa_id);
    my $currencies;
    if($self->{currencies}){
        $currencies = $self->{currencies};
    }else{
        $currencies = \@currencies;
    
    }
    my $opers=get_operators();
    use Data::Dumper;
    shift @{$opers};
    foreach my $oper(@{$opers})
    {
    	$oper->{title} .= "(id#$oper->{o_id})";
    }
    $proto={
        'table'=>"cashier_transactions",  
        'template_prefix'=>"cashier_out2",
        'sort'=>'ct_date DESC,ct_oid ',
        'page_title'=>"Получение наличных из кассы $proto->{cash_title}",
        'extra_where'=>"ct_amnt < 0 AND ct_fid=$kassa_id AND ct_status='created'",
        'extra_where2'=>"ct_amnt < 0 AND ct_fid=$kassa_id AND ct_status NOT IN ('created','deleted')", #for second table (@rows2)
        
        'need_confirmation'=>1,  
        
        'fields'=>[
            {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1,filter=>'=','filter_invisible'=>'1'},    
            {'field'=>"ct_date", "no_add_edit"=>1, "title"=>"Дата Создания", 'filter'=>"time"},
        
            {'field'=>"ct_aid", "title"=>"Карточка", "no_add_edit"=>1, "category"=>"accounts",
	        'type'=>'select',
	        'filter'=>'='
	        },
            {'field'=>"ct_amnt", "title"=>"Сумма", "no_add_edit"=>1, "op"=>"-", 'filter'=>"eq"},
            {'field'=>'ct_req',no_add_edit=>1,edit_expr=>"'no'",'no_view'=>1},
            {'field'=>"ct_currency", "title"=>"Валюта", "no_add_edit"=>1
            , "type"=>"select"
            , "titles"=>$currencies
            , 'filter'=>"="
            },
            {'field'=>"ct_comment", "title"=>"Назначение", "no_add_edit"=>1,filter=>'like'},
            {'field'=>"ct_oid", "title"=>"Оператор"
            , "no_add_edit"=>1, "category"=>"operators" 
            , "type"=>"select"
            , "titles"=>$opers
            },
        
            #{'field'=>"ct_tid", "title"=>"Транзакция", "no_add_edit"=>1,},
        
            {'field'=>"ct_ts2", "no_add_edit"=>1, "title"=>"Дата Выдачи", 
            "no_view"=>1},  
        
            {
            'field'=>"ct_status", filter=>'=',"title"=>"Статус Выдачи"
            , "type"=>"select"
            , "titles"=>[
                {'value'=>"created", 'title'=>"в процессе"},
                {'value'=>"processed", 'title'=>"выдан"},
                {'value'=>"canceled", 'title'=>"отменен"},
            ]
        
            },
        
            {'field'=>"ct_oid2", "title"=>"Оператор Выдачи"
            , "no_add_edit"=>1, 'edit_expr'=>"1", "category"=>"operators"
            ,"no_view"=>1,"type"=>"select"
            , "titles"=>$opers
            },
            {'field'=>"ct_tid2", "title"=>"Транзакция Выдачи"
            , "no_add_edit"=>1, 'edit_expr'=>"1"
            ,"no_view"=>1,
            },
        
        
        ],
        "formats"=>["ct_amnt","ct_aid","ct_currency","ct_status","ct_oid2","ct_oid"],
        "output_formats"=>['ct_amnt','ct_ts2','ct_ts']
        };  
        $proto->{cash}=$kassa_id;
        $proto->{cash_title}=$kassa_title;
	    $proto->{cash_rows}=get_avail_cash_offices($self);
	     
        $proto->{fields}->[2]->{'titles'}=&get_accounts_simple();
        $proto->{active_blocking}=$dbh->selectrow_array(q[SELECT cob_id 
        FROM cashier_out_block 
        WHERE 
        DATE(cob_date)=DATE(current_timestamp) 
        AND cob_coid=? 
        AND cob_block='yes'],undef,$co_id);
        return 'cash_out2_'.$self->{cash};
}

sub setup
{
  my $self = shift;
  $self->start_mode('list');
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'add'  => 'add',
    'edit' => 'edit',
    'del_blocking'=>'del_blocking',
    'add_blocking'=>'add_blocking',
    'back'=>'back'
  );
}
sub del_blocking{
    my $self=shift;
    $dbh->do(q[UPDATE cashier_out_block 
                SET cob_block='deleted' 
                WHERE DATE(cob_date)=DATE(current_timestamp) AND cob_coid=? ],undef,$co_id);
    $self->header_type('redirect');
    return $self->header_add(-url=>'?');

}
sub add_blocking{
     my $self=shift;
     $dbh->do(q[INSERT INTO 
                cashier_out_block SET cob_block='yes',cob_coid=? ],undef,$co_id);

    $self->header_type('redirect');

    return $self->header_add(-url=>'?');

}
sub back{

    my $self=shift;
    my $id=$self->query->param('ct_id');
    $self->header_type('redirect');
    my $cash=$self->{cash};
    return $self->header_add(-url=>qq[cashier_input_before_$cash.cgi?do=back&ct_id=$id]);

}
sub list
{
   		my $self = shift;
   		$self->get_cash_conclusions($proto);
        return $self->proto_list_fast($proto);
}
sub add
{
   my $self = shift;
	##delete keys for field ct_aid for normal working search field 	
   delete $proto->{fields}->[2]->{filter};
   delete $proto->{fields}->[2]->{type};
   delete $proto->{fields}->[2]->{titles};
	
    $proto->{page_title}="Вывод наличных $proto->{cash_title}";

   return $self->proto_add_edit('add', $proto);
}

sub edit
{
   my $self = shift;
    $proto->{page_title}="Вывод наличных $proto->{cash_title}";
   delete $proto->{fields}->[2]->{filter};
   delete $proto->{fields}->[2]->{type};
   delete $proto->{fields}->[2]->{titles};
   return $self->proto_add_edit('edit', $proto);
}


sub proto_add_edit_trigger{
  my $self=shift;
  my $params = shift;    
	
   if($params->{step} eq 'before'){
   my $id = $self->query->param('id');
   my $status = $self->query->param('ct_status');
   my $r = $dbh->selectrow_hashref("SELECT * FROM $params->{p}->{table} 
	WHERE ct_status='created' AND $params->{p}->{id_field} = ".sql_val($id));
	

   if( $r && ($status eq 'processed' || $status eq 'canceled') ){
   
    
 
    my $comment = $r->{ct_comment};
	die "Заполните поле комментариев \n" unless($comment);
	


    	my $tid;


	if($status ne 'canceled')
	{
	    my $percent=0;
       my $income_card=$dbh->selectrow_array(q[SELECT a.a_id 
        FROM accounts as a 
        WHERE a_id IN 
        (SELECT s.a_incom_id FROM accounts as s WHERE s.a_id=?)],undef,$r->{ct_aid});
        die "У данной программы нет в настройках приходной\n"    if(!$income_card&&$r->{ct_ext_commission}>0);
	    my $comis_tid='NULL';
        if($r->{ct_comis_percent})
        {

            
##(2*9816.70062)/(2*53.55)
         #   my $k=((1-$r->{ct_comis_percent}/100)*100)/$r->{ct_comis_percent}-1;
          #  $percent=abs((2*$r->{ct_amnt})/(2*$k));
            
            my $amnt=$self->query->param('ct_amnt');
            $percent=$r->{'ct_comis_percent'};
                     

            $percent=abs(($percent*(($amnt/(1-$percent/100))/100)));

            $comis_tid=$self->add_trans({
                t_name1 => $r->{ct_aid},
                t_name2 => $comis_aid,
                t_currency => $r->{'ct_currency'},
                t_amnt => $percent,
                t_comment=>$comment
            });
            $percent=-$percent;

        }
        
    


        if(0&&$r->{ct_ext_commission}>0){

            $tid=$self->add_trans({
                t_name1 => $r->{ct_aid},
                t_name2 => $income_card,
                t_currency => $r->{'ct_currency'},
                t_amnt => $r->{ct_ext_commission},
                t_comment=>$comment
            });
        }



    
        

	    $tid=$self->add_trans({
			t_name1 => $r->{ct_aid},
			t_name2 => $kassa_id,
			t_currency => $r->{'ct_currency'},
			t_amnt => abs($r->{'ct_amnt'}),
			t_comment=>$comment
		});
		
		$dbh->do("UPDATE cashier_transactions SET 
		 ct_status='processed',ct_req='no',ct_oid2=?,ct_ts2=NOW(),ct_tid=?,ct_tid2_comis=$comis_tid WHERE ct_id=?", undef, 
		$self->{user_id},$tid, $id);
		
    		$r->{ct_ext_commission}=0 unless($r->{ct_ext_commission});
	
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
			 $percent,
			(`cashier_transactions`.`ct_amnt`+$percent+-1*$r->{ct_ext_commission}) AS `result_amnt`,
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
			IN (_cp1251'processed')  AND ct_id=? LIMIT 1
			],undef,$id);	

	
	}else
	{
	
		$dbh->do("UPDATE cashier_transactions SET 
	 	ct_status='canceled',ct_oid2=?,ct_ts2=NOW() WHERE ct_id=?", undef, 
		$self->{user_id}, $id);

	}
			$self->header_type('redirect');
			return $self->header_add(-url=>'?');
      

	}
	
	}
}


1;
