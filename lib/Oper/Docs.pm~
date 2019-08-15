package Oper::Docs;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
use Documents;

my $proto;
sub get_right{       
     my $self=shift;
   


 $proto={
    'table'=>"documents_requests",  
    'template_prefix'=>"docs_trans",
    'need_confirmation'=>0,
    'extra_where'=>"dr_status NOT IN ('deleted','canceled') ",
    'page_title'=>"Документы по фирмам",
    'sort'=>'dr_date DESC,dr_fid',
    'key_hashes'=>['key_field','dr_fid','dr_aid','dr_id'],
    'fields'=>[
        {'field'=>"dr_ts", "no_add_edit"=>1, "no_view"=>1, "title"=>"Дата",},
        {
	    'field'=>"dr_fid", "title"=>"Фирма", 'filter'=>"="
        , "type"=>"select",
        , "category"=>'firms',select_search=>1
    
        },
#         {
#             
#         'field'=>"okpo", "title"=>"окпо фирмы(поку-ля)", 'filter'=>"="
#         , "type"=>"select",
#             select_search=>1,
#             no_add_edit=>1,
#         },    
#     
#         {
#         'field'=>"dr_ofid_from", "title"=>"Покупатель", 'filter'=>"="
#         , "type"=>"select",
#         , "category"=>'out_firms',
#             another_enable=>1,select_search=>1
#     
#         },
     {
     'field'=>"dr_aid", "title"=>"Программа", "category"=>"accounts",
 	    'type'=>'select',
	    'no_add_edit'=>1,
 	    'filter'=>'=',select_search=>1
         },
#         {
#         'field'=>"a_incom_id", 
# 	    "title"=>"Программа",
# 	    'type'=>'select',
#     
# 	    'no_add_edit'=>1,
#         
#     
#         },
        {'field'=>"dr_amnt", "title"=>"Сумма", 'positive'=>1,filter=>'eq'},
        {'field'=>"dr_currency", "title"=>"Валюта", 
	    'titles'=>\@currencies,
	    'type'=>'select'
        },
#         {'field'=>"dr_comis", "title"=>"Комиссия%",  'positive'=>1},
    
        {'field'=>"sum_comis",no_add_edit=>1, "title"=>"Сумма ком-ии",  'positive'=>1,filter=>'eq'},
    
        {'field'=>"is_payed",no_add_edit=>1, "title"=>"Оплата",type=>'select',filter=>'=', titles=>[{
        value=>0,
        title=>'Не оплаченна'
        },{
            value=>1,
            title=>'Оплачена'
        }
        ]},
#         { 'field'=>"dr_status",
#             no_add_edit=>1, 
#             "title"=>"Статус проведения",type=>'select',filter=>'=', titles=>[{
#         value=>'created',
#         title=>'Не закрыта'
#         },{
#             value=>'processed',
#             title=>'Закрыта'
#         }
#         ]},
    
    
        {'field'=>"dr_date", "title"=>"Дата",  'category'=>"date",'filter'=>"time"},
    
        {'field'=>"dr_comment", "title"=>"Назначение", },
    ],
        formating=>{dr_date=>'month_year'},
        "formats"=>["dr_currency",'is_payed','dr_status','dr_fid','dr_aid','a_incom_id','dr_ofid_from','okpo'],
        "output_formats"=>["sum_comis",'dr_amnt','payed_comis','payed_income','dr_date']
    };	
#     my @arr = get_out_firms_and_okpo();
#     $proto->{fields}->[2]->{titles}=$arr[0];
#     $proto->{fields}->[3]->{titles}=$arr[1];
    #$proto->{fields}->[2]->{titles}=&get_out_firms_okpo();
    #$proto->{fields}->[3]->{titles}=&get_out_firms();
#     $proto->{fields}->[4]->{titles}=&get_accounts_simple($CLIENT_CATEGORY);
    $proto->{fields}->[2]->{titles}=&get_accounts_simple(undef,{currency=>'a_uah'});


    return 'docs';
}
sub setup{
  my $self = shift;
  $self->start_mode('list');
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'add'=>'add',
    'edit'=>'edit',
    'del'=>'del',
    'close_deals'=>'close_deals',
    'get_payement'=>'get_payement',
    'docs_common_confirm'=>'docs_common_confirm',
    'get_payment_do'=>'get_payment_do',
    

  );
}
sub close_deals{
	
    my $self=shift;
    return ;
    my @id=$self->query->param(q[id]);
    require Oper::Ajax;
    my $res;  
    foreach my $tmp (@id){
        $tmp=$tmp*1;
        $res=Oper::Ajax::ajax_close_deal($self,$tmp) if($tmp);
    }
    $self->header_type('redirect');
    return $self->header_add(-url=>'?');

}
sub list{
	my $self = shift;
    
    $self->{tpl_vars}->{accounts}=&get_accounts_simple($CLIENT_CATEGORY);
	
# 	$proto->{table}='documents_view_income';
 	#$proto->{group}='group by `dr_fid`,`dr_aid`,`dr_currency`,`dr_ofid_from`,`dr_status`,dr_date';

#	my $params=$self->get_proto_list($proto);
	my $params=$self->get_documents_list($proto);

	#die($TIMER->stop);

	#set_calc_persent_comissions($params);
	$params->{file}='docs_trans_list.html';
	return $self->template_proto_list($params);
	
}
sub edit{
    my $self=shift;
   
   my  $proto={
  'table'=>"documents_requests",  
  'template_prefix'=>"docs_trans",
  'need_confirmation'=>0,
  'edit_where'=>"dr_status  IN ('created') ",

  'page_title'=>"Документы по фирмам",
   'fields'=>[
    {'field'=>'dr_id',"no_add_edit"=>1, "no_view"=>1,},
    {'field'=>"dr_ts", "no_add_edit"=>1, "no_view"=>1, "title"=>"Дата",},
    {
    'field'=>"dr_fid", "title"=>"Фирма", 'filter'=>"="
      , "type"=>"select",
      , "category"=>'firms'

    },
#     {
#       'field'=>"dr_ofid_from", "title"=>"Покупатель", 'filter'=>"="
#       , "type"=>"select",
#       ,'titles'=>&get_out_firms(),
#       , "category"=>'out_firms',
#         another_enable=>1,
# 
#     },
#     {
#     'field'=>"dr_aid",no_add_edit=>1, "title"=>"Программа", "category"=>"accounts",
#     'filter'=>'='
#     },

    {'field'=>"dr_amnt", "title"=>"Сумма",filter=>'eq'},
    {
    'field'=>"dr_currency", "title"=>"Валюта", 
    'titles'=>\@currencies,
    'type'=>'select'
    },
#     {'field'=>"dr_comis", "title"=>"Комиссия%",  'positive'=>1},
    {'field'=>"dr_date", "title"=>"Дата",  'category'=>"date",'filter'=>"time"},
     {'field'=>"dr_comment", "title"=>"Назначение", },
    ],
   };
  
    return $self->proto_add_edit('edit', $proto);


}

sub add
{
	my $self = shift;
	my $id=$self->query->param('pay');
	###another way of processing credits
	if($id)
	{
		my $proto={
			'table'=>"documents_requests_logs",
			'template_prefix'=>"docs_trans",
			'need_confirmation'=>0,
			'extra_where'=>"dr_status='created' ",
			'page_title'=>"Документы по фирмам",
			'sort'=>'dr_ts DESC',
			'key_hashes'=>['key_field','dr_fid','dr_aid'],
			'fields'=>[
			{'field'=>"dr_ts", "no_add_edit"=>1, "no_view"=>1, "title"=>"Дата",},
			{
				'field'=>"dr_fid", "title"=>"Фирма", 'filter'=>"="
				, "type"=>"select",
				, "category"=>'firms'
			
			},
			{'field'=>"pay",  "no_view"=>1,'system'=>1},
# 			{
# 			'field'=>"dr_ofid_from", "title"=>"Покупатель", 
# 			, "type"=>"select",'titles'=>&get_out_firms(),
#         
# 
# 			},
			{'field'=>"dr_amnt", "title"=>"Сумма",  'filter'=>"eq",'positive'=>1},
			{'field'=>"dr_currency", "title"=>"Валюта", 
				'titles'=>\@currencies,
				'type'=>'select'
			},
# 			{
# 				'field'=>"dr_comis", "title"=>"Процент",  'positive'=>1
# 			},
# 			{
# 				'field'=>"dr_aid", "title"=>"Документы"
# 			},
			{'field'=>"dr_comment", "title"=>"Назначение", },
			{'field'=>"dr_date", "title"=>"Дата",category=>'date', filter=>'time' },
			],
		};
	    return $self->proto_add_edit('add', $proto);

	}
	$proto->{table}='documents_requests_logs';
# 	delete $proto->{fields}->[3]->{filter};
#    	delete $proto->{fields}->[3]->{type};
#    	delete $proto->{fields}->[3]->{titles};
	
	delete $proto->{fields}->[2]->{category};

	return $self->proto_add_edit('add', $proto);

}

sub get_payement
{
	my $self=shift;

	my @ids=$self->query->param('id');
	my @res_ids=map{ $_=int($_) } @ids;
	my $ids=join(",",@res_ids);
	my $res=$dbh->selectall_hashref(qq[SELECT dr_date,dr_id,dr_comment,dr_fid as f_id,f_name,dr_amnt,dr_currency 
					   FROM documents_requests,firms 
					   WHERE dr_status='created' AND f_id=dr_fid AND dr_id IN ($ids)],"dr_id");    
	
	my $tmpl=$self->load_tmpl('docs_common_input2.html');
	$self->{tpl_vars}->{services}=get_services();
        my $sum=0;
	my @res=map { $sum+=abs($res->{$_}->{dr_amnt});
	$res->{$_}->{dr_amnt}=format_float($res->{$_}->{dr_amnt});
	$res->{$_}->{dr_date}=format_datetime_month_year(\$res->{$_}->{dr_date});
	$res->{$_} } keys %$res;
	$self->{tpl_vars}->{list}=\@res;
	$self->{tpl_vars}->{sum}=$sum;
	$self->{tpl_vars}->{page_title}="Проведение документов";
	
	my $output;
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;

}

sub docs_common_confirm{
      my $self=shift;
      my @ids=$self->query->param('dr_id');
      my $percent=$self->query->param('ct_comis_percent');
      my $fsid=$self->query->param('ct_fsid');
      my $aid=$self->query->param('ct_aid');
      my $ct_ts2=$self->query->param('ct_ts2');


      

      my @res_ids=map{ $_=int($_) } @ids;
      my $ids=join(",",@res_ids);
      my $res=$dbh->selectall_hashref(qq[SELECT dr_date,dr_id,dr_comment,dr_fid as f_id,f_name,dr_amnt,dr_currency 
					   FROM documents_requests,firms 
					   WHERE dr_status='created' AND f_id=dr_fid AND dr_id IN ($ids)],"dr_id");    
	
	my $tmpl=$self->load_tmpl('docs_common_confirm.html');
	
        my $sum=0;
	my @res=map { $sum+=abs($res->{$_}->{dr_amnt});
	$res->{$_}->{dr_amnt}=format_float($res->{$_}->{dr_amnt});
	$res->{$_}->{dr_date}=format_datetime_month_year(\$res->{$_}->{dr_date});
	$res->{$_} } keys %$res;

	$self->{tpl_vars}->{list}=\@res;
	$self->{tpl_vars}->{sum}=format_float ($sum);
	$self->{tpl_vars}->{common_sum}= format_float( $sum-$percent*($sum/100) );
	$self->{tpl_vars}->{comission}= format_float( $percent*($sum/100) );

	$self->{tpl_vars}->{ct_comis_percent}= $percent;
	my $a_name=$dbh->selectrow_array(q[SELECT a_name FROM accounts WHERE a_id=? AND a_status='active'],undef,$aid);
	$self->{tpl_vars}->{a_id}= $aid;
	$self->{tpl_vars}->{a_name}= $a_name;
	
	$self->{tpl_vars}->{ct_ts2_format}= format_date($ct_ts2);
	$self->{tpl_vars}->{ct_ts2}= $ct_ts2;
	my $fs_name=$dbh->selectrow_array(q[SELECT fs_name FROM firm_services WHERE fs_id=? AND fs_status='active'],undef,$fsid);
	$self->{tpl_vars}->{fs_name}= $fs_name;
	$self->{tpl_vars}->{fs_id}= $fsid;
	$self->{tpl_vars}->{page_title}="Подтверждение проведение документов";
	


	my $output;
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;




}
sub get_payment_do{
    my $self=shift;
    my @ids=$self->query->param('dr_id');
    my $ct_comis_percent=$self->query->param('ct_comis_percent');
    my $fsid=$self->query->param('ct_fsid');
    my $aid=$self->query->param('ct_aid');
    my $ct_ts2=$self->query->param('ct_ts2');
    my $a_name=$dbh->selectrow_array(q[SELECT a_name FROM accounts WHERE a_id=? AND a_status='active'],undef,$aid);
    die " Вы не выбрали программу" unless($a_name);
    my $fs_name=$dbh->selectrow_array(q[SELECT fs_name FROM firm_services WHERE fs_id=? AND fs_status='active'],undef,$fsid);

      my @res_ids=map{ $_=int($_) } @ids;
      my $ids=join(",",@res_ids);

      my $res=$dbh->selectall_hashref(qq[SELECT dr_date,dr_id,dr_comment,dr_fid as f_id,f_name,dr_amnt,dr_currency 
					   FROM documents_requests,firms 
					   WHERE dr_status='created' AND f_id=dr_fid AND dr_id IN ($ids)],"dr_id");  
      foreach(keys %$res){
	  my $tmp=$res->{$_};
	  my $amnt=abs($tmp->{dr_amnt});
	  my $comis=$ct_comis_percent*($amnt/100);
	  $dbh->do(q[UPDATE documents_requests SET dr_comis=? WHERE dr_id=?],undef,$ct_comis_percent,$_);
	   $tmp->{dr_date}=format_datetime_month_year(\$tmp->{dr_date});
	 my $tid=$self->add_trans({  
						        t_status=>'system',
						        t_amnt=>$comis,
						        t_currency=>$tmp->{dr_currency},
						        t_name1 => $aid ,
						        t_name2 => $comis_aid,
						        t_comment => "Плата $ct_comis_percent % $tmp->{dr_date} за услугу $tmp->{dr_date}  c  фирмы $tmp->{f_name}  #$tmp->{dr_comment} ",
						    });
                     



	  $dbh->do(q[ INSERT INTO documents_payments(dp_amnt,dp_drid,dp_tid) VALUES(?,?,?)],undef,$comis,$_,$tid);
	

      }
    $self->header_type('redirect');
    return $self->header_add(-url=>'?do=list');   


}

sub proto_add_edit_trigger{
	my $self=shift;
  	my $params = shift;
	my %q;
	map { $q{$_}=$self->query->param($_) } $self->query->param();
	

    if($params->{method} eq 'edit'&&$params->{step} eq 'operation')
    {
            
            
           ###there can be races
           ####use locks table
   
          my $ref=$dbh->selectrow_hashref(q[SELECT * 
            FROM 
            documents_requests WHERE dr_id=? AND dr_status IN ('created','processed')
            ],undef,$q{id});
            return    unless($ref->{dr_id});

#commenting this objections
#            $params->{sql}.=" AND dr_status='created'";
            
            $dbh->do($params->{sql});
    
            $dbh->do(q[UPDATE 
                        documents_transactions 
                        SET 
                        dt_date=?,
                        dt_fid=?,
                        dt_ofid=?,
                        dt_currency=? 
                        WHERE
                        dt_drid=?
                        ],undef,
                        $q{dr_date},
                        $q{dr_fid},
                        $q{dr_ofid_from},
                        $q{dr_currency},
                        $q{id});
 
            my $comis={amnt=>0};

            my $dp_ids=$dbh->selectall_hashref(qq[
                    SELECT dp_amnt as amnt,dp_id
                    FROM documents_payments
                    WHERE dp_drid=$q{id} AND dp_amnt!=0 ],'dp_id');

            map { $comis->{amnt}+=$dp_ids->{$_}->{amnt} } keys %{$dp_ids};
            
            if($q{dr_comis}!=$ref->{dr_comis}&&$comis->{amnt}>0)
            {
                

                    require Oper::Ajax;
                    map{ Oper::Ajax::delete_document_payment($self,$_) } keys %{$dp_ids};
                    my @aa=($q{id});
                    get_payment_($self,\@aa);


            }
                     


	}elsif($params->{method} eq 'add'&&$params->{step} eq 'operation')
	{
		$dbh->do($params->{sql});
		my $doc_id=$dbh->selectrow_array(q[SELECT last_insert_id() ]);
  

		$q{doc_id}=$doc_id;
		$q{user_id}=$self->{user_id};
		add_document(\%q);

		
	
	}elsif($params->{step} eq 'before'&&$params->{method} eq 'add')
	{
		##if it a credit make a sum negative
		if($q{pay})
		{
			$self->query->param('dr_amnt',-1*$q{dr_amnt});
# 			$self->query->param('dr_aid',$DOCUMENTS);
		}
		##
# 		$self->query->param('dr_oid',$self->{user_id});
# 		my @of_id_=$self->query->param('dr_ofid_from');
		
# 		my $of_id=$dbh->selectrow_array(q[SELECT of_id FROM out_firms 
# 		WHERE of_id=? OR of_name=?],undef,$of_id_[0],$of_id_[1]);
# 		unless($of_id)
# 		{
# 			$dbh->do(q[INSERT INTO out_firms(of_name) VALUES(?)],undef,$of_id_[1]);
# 			$self->query->param('dr_ofid_from',$dbh->selectrow_array(q[SELECT last_insert_id() ]));

# 		}else
# 		{
# 			$self->query->param('dr_ofid_from',$of_id);
# 		}
		
	
	}




}





1;
