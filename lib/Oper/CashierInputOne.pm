package Oper::CashierInputOne;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $proto;
my $kassa_id;
sub get_right
{
    my $self=shift;
    my $kassa_title;
    ($kassa_id,$kassa_title, $ex)=$dbh->selectrow_array(q[SELECT co_aid,co_title, co_script_ex
                                      FROM cash_offices 
                                      WHERE co_name=?],undef,$self->{cash});    
    return 'denied'    unless($kassa_id);

    $proto={
        'table'=>"cashier_transactions", 
        'page_title'=>"Ввод наличных $kassa_title одним шагом",
        'sort'=>'ct_date DESC,ct_oid ',
        'id_field'=>'ct_id',
        'extra_where'=>"ct_amnt > 0 AND ct_fid=$kassa_id AND ct_status!='deleted' ",  #AND ct_status='created'
        'need_confirmation'=>1,
        'template_prefix'=>"cashier_in_one",
        'fields'=>[
            {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1,filter=>'=','filter_invisible'=>'1'},    
            {'field'=>"ct_date",  "title"=>"Дата", 'filter'=>"time",category=>'date'},
            {'field'=>"ct_ts2", "no_add_edit"=>1,'no_view'=>1},
            {'field'=>'ct_req',"no_add_edit"=>1,'no_view'=>1,"edit_expr"=>"'no'"},
            {'field'=>"ct_aid", "title"=>"Карточка", "category"=>"accounts",
            'type'=>'select',
            'filter'=>'=',
            },
            {'field'=>"ct_amnt",
            "title"=>"Сумма",
            'filter'=>"eq",
            },
            {'field'=>"ct_currency", "title"=>"Валюта"
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
            {'field'=>"ct_oid", "title"=>"Оператор получивший"
            , "no_add_edit"=>1,"no_view"=>1, "category"=>"operators"
            },
            {'field'=>"ct_tid", "title"=>"Транзакция"
            , "no_add_edit"=>1,'no_view'=>1
            }, 
            {'field'=>'ct_fid',"no_add_edit"=>1,'no_view'=>1},
            {'field'=>"ct_ts", "no_add_edit"=>1,'no_view'=>1},


        ],
        };  
        $proto->{fields}->[4]->{'titles'}=&get_accounts_simple();
        $proto->{cash}=$kassa_id;
        $proto->{ex} = $ex;
        $proto->{cash_title}=$kassa_title;

        return 'cash_in_one_'.$self->{cash};
}

sub setup
{
  my $self = shift;
  $self->start_mode('list');
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'add' => 'add',
    're_proc'=>'re_proc',
    'back'=>'back',
    'edit'=>'edit'
  );
}
sub edit
{
   my $self = shift;
     
   delete $proto->{fields}->[4]->{filter};
   delete $proto->{fields}->[4]->{type};
   delete $proto->{fields}->[4]->{titles};
    


   return $self->proto_add_edit('edit', $proto);


} 

sub list
{
   my $self = shift;
   $self->get_cash_conclusions($proto);
   return $self->proto_list($proto);

}

sub add
{
   my $self = shift;
   return $self->proto_add_edit('add', $proto);


}
sub back{
    
    my $self=shift;
    my $id=$self->query->param('ct_id');
    $self->header_type('redirect');
    my $cash=$proto->{ex};
    return $self->header_add(-url=>qq[cashier_output_$cash.cgi?do=back&ct_id=$id]);
    
    
}

sub proto_add_edit_trigger{
    my $self=shift;
    my $params = shift;    
   
    
    

  if($params->{step} eq 'before'){

    my $com=$self->query->param('ct_comment');
    my $amnt=$self->query->param('ct_amnt');
    my $currency=$self->query->param('ct_currency');
    my $id=$self->query->param('id');
    my $cash=$proto->{ex};

    if($id){
        
        my $res=$dbh->do(q[UPDATE cashier_transactions 
                      SET ct_status='processing' WHERE ct_id=?
                      AND ct_status='created'
                     ],undef,$id);
        
        if($res ne '1'){
        
            $self->header_type('redirect');
            return $self->header_add(-url=>qq[cashier_output_$cash.cgi?do=list]);
        }

    }
    
    
    my $aid=$self->query->param('ct_aid');
    $aid=$dbh->selectrow_array(q[SELECT a_id FROM accounts WHERE a_id=? AND a_id>0 ],undef,$aid);

    $amnt=~s/[,]/\./g;
    $amnt=~s/[ -]//g;
    $amnt=$amnt*1;
    die "Такой программы не существует \n" unless($aid);
    die "Такая валюта не поддерживается \n" unless($conv_currency->{$currency});
    die "Неправильный формат суммы \n"     unless($amnt);

    $self->query->param('ct_amnt',$amnt);
    die "Заполните поле комментариев \n"    unless(trim($com));
   
    my $tid_comis='NULL';
    
    

   my $tid = $self->add_trans({
    t_name1 => $kassa_id,
    t_name2 =>$aid,
    t_currency =>$currency,
    t_amnt => $amnt,
    t_comment => $self->query->param('ct_comment'),
   });

   foreach my $row( @{$params->{proto}->{fields}} ){
     if($row->{field} eq 'ct_oid'){
       $row->{expr} = $self->{user_id}
     }elsif($row->{field} eq 'ct_tid'){
       $row->{expr} = $tid;
     }elsif($row->{field} eq 'ct_status'){
       $row->{expr} = "'processed'";
       
     }elsif($row->{field} eq 'ct_ts2')
     {

        $row->{expr} = "NOW()"; 

     }elsif($row->{field} eq 'ct_ts')
     {

        $row->{expr} = "NOW()"; 

     }elsif($row->{field} eq 'ct_fid'){
       $row->{expr} = $kassa_id;
     }  
   }

   return 1;   

  }elsif($params->{step} eq 'operation'){
    $dbh->do($params->{sql});
    ###it fucking wrong!!
    
    my $id=$self->query->param('id');

    unless($id){ 
	$id=$dbh->selectrow_array(q[SELECT last_insert_id()]);
    }
    
    ##this
    my $percent=0;
    my $sum_comis=0;
    $percent =0;
    $sum_comis=0;
    $sum_comis=0;

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
     where  `cashier_transactions`.`ct_status` 
    in (_cp1251'processed')  AND ct_id=? LIMIT 1
    ],undef,$id); 
    

  }

}


1;
