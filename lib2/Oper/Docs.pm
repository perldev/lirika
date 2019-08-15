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
    'sort'=>'dr_date DESC',
    'key_hashes'=>['key_field','dr_fid','dr_aid','dr_id'],
    'fields'=>[
        {'field'=>"dr_ts", "no_add_edit"=>1, "no_view"=>1, "title"=>"Дата",},
        {
	    'field'=>"dr_fid", "title"=>"Фирма", 'filter'=>"="
        , "type"=>"select",
        , "category"=>'firms',select_search=>1
    
        },
        {
            
        'field'=>"okpo", "title"=>"окпо фирмы(поку-ля)", 'filter'=>"="
        , "type"=>"select",
            select_search=>1,
            no_add_edit=>1,
        },    
    
        {
        'field'=>"dr_ofid_from", "title"=>"Покупатель", 'filter'=>"="
        , "type"=>"select",
        , "category"=>'out_firms',
            another_enable=>1,select_search=>1
    
        },
    {
    'field'=>"dr_aid", "title"=>"Программа", "category"=>"accounts",
	    'type'=>'select',
    
	    'filter'=>'=',select_search=>1
        },
        {
        'field'=>"a_incom_id", 
	    "title"=>"Программа",
	    'type'=>'select',
    
	    'no_add_edit'=>1,
        
    
        },
        {'field'=>"dr_amnt", "title"=>"Сумма", 'positive'=>1,filter=>'='},
        {'field'=>"dr_currency", "title"=>"Валюта", 
	    'titles'=>\@currencies,
	    'type'=>'select'
        },
        {'field'=>"dr_comis", "title"=>"Комиссия%",  'positive'=>1},
    
        {'field'=>"sum_comis",no_add_edit=>1, "title"=>"Сумма ком-ии",  'positive'=>1,filter=>'='},
    
        {'field'=>"is_payed",no_add_edit=>1, "title"=>"Оплата",type=>'select',filter=>'=', titles=>[{
        value=>0,
        title=>'Не оплаченна'
        },{
            value=>1,
            title=>'Оплачена'
        }
        ]},
        { 'field'=>"dr_status",
            no_add_edit=>1, 
            "title"=>"Статус проведения",type=>'select',filter=>'=', titles=>[{
        value=>'created',
        title=>'Не закрыта'
        },{
            value=>'processed',
            title=>'Закрыта'
        }
        ]},
    
    
        {'field'=>"dr_date", "title"=>"Дата",  'category'=>"date",'filter'=>"time"},
    
        {'field'=>"dr_comment", "title"=>"Назначение", },
    ],
        formating=>{dr_date=>'month_year'}    
    
    };	
    $proto->{fields}->[2]->{titles}=&get_out_firms_okpo();
    $proto->{fields}->[3]->{titles}=&get_out_firms();
    $proto->{fields}->[4]->{titles}=&get_accounts_simple($CLIENT_CATEGORY);
    $proto->{fields}->[5]->{titles}=&get_accounts_simple(undef,{currency=>'a_uah'});


    return 'docs';
}
sub setup{
  my $self = shift;
  
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'add'=>'add',
    'edit'=>'edit',
    'del'=>'del',
    'close_deals'=>'close_deals',
    'get_payement'=>'get_payement',

  );
}
sub close_deals{

    my $self=shift;
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
	
	$proto->{table}='documents_view_income';
# 	$proto->{group}='group by `dr_fid`,`dr_aid`,`dr_currency`,`dr_ofid_from`,`dr_status`,dr_date';
	my $params=$self->get_proto_list($proto);	
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

  'page_title'=>"Документы по фирмам",
   'fields'=>[
    {'field'=>'dr_id',"no_add_edit"=>1, "no_view"=>1,},
    {'field'=>"dr_ts", "no_add_edit"=>1, "no_view"=>1, "title"=>"Дата",},
    {
    'field'=>"dr_fid", "title"=>"Фирма", 'filter'=>"="
      , "type"=>"select",
      , "category"=>'firms'

    },
    {
      'field'=>"dr_ofid_from", "title"=>"Покупатель", 'filter'=>"="
      , "type"=>"select",
      ,'titles'=>&get_out_firms(),
      , "category"=>'out_firms',
        another_enable=>1,

    },
    {
    'field'=>"dr_aid",no_add_edit=>1, "title"=>"Программа", "category"=>"accounts",
    'filter'=>'='
    },

    {'field'=>"dr_amnt", "title"=>"Сумма", 'positive'=>1,filter=>'='},
    {
    'field'=>"dr_currency", "title"=>"Валюта", 
    'titles'=>\@currencies,
    'type'=>'select'
    },
    {'field'=>"dr_comis", "title"=>"Комиссия%",  'positive'=>1},
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
			{
			  'field'=>"dr_ofid_from", "title"=>"Покупатель", 'filter'=>"="
		 	, "type"=>"select",
      			,'titles'=>&get_out_firms(),
			 another_enable=>1,
			
			},
			{'field'=>"dr_amnt", "title"=>"Сумма",  'filter'=>"=",'positive'=>1},
			{'field'=>"dr_currency", "title"=>"Валюта", 
				'titles'=>\@currencies,
				'type'=>'select'
			},
			{
				'field'=>"dr_comis", "title"=>"Процент",  'positive'=>1
			},
			{
				'field'=>"dr_aid", "title"=>"Документы",'no_add_edit'=>1,'expr'=>$DOCUMENTS
			},
			{'field'=>"dr_comment", "title"=>"Назначение", },
			{'field'=>"dr_date", "title"=>"Дата",caregory=>'date' },
			],
		};
				
	    return $self->proto_add_edit('add', $proto);

	}
	$proto->{table}='documents_requests_logs';
	delete $proto->{fields}->[3]->{filter};
   	delete $proto->{fields}->[3]->{type};
   	delete $proto->{fields}->[3]->{titles};
	
	delete $proto->{fields}->[2]->{category};

	return $self->proto_add_edit('add', $proto);

}

sub get_payement
{
	my $self=shift;
	my @ids=$self->query->param('id');
	
	get_payment_($self,\@ids);


	$self->header_type('redirect');
	return $self->header_add(-url=>'?');



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
=for comments
                    my $dt=$dbh->selectall_arrayref(q[SELECT dt_amnt,dt_id FROM documents_transactions 
                    WHERE dt_drid=?  AND dt_status IN ('processed')],undef,$q{id});
            
                    my $dt_c=$dbh->selectall_arrayref(q[SELECT dt_amnt,dt_id FROM documents_transactions 
                    WHERE dt_drid=?  AND dt_status IN ('created')],undef,$q{id});
                
               
                    my $payed_sum=($comis->{amnt}*100)/$q{dr_comis}; 
                    
                    my ($tmp_sum,@tmp_tids);
                    $tmp_sum=0;
                    foreach(@$dt)
                    {
                           $tmp_sum+=$_->[0];
                           push @tmp_tids,$_->[1];
                    }
                    

                    if($tmp_sum>$payed_sum)
                    {
                           my $sum=0;
                           my (@to_make_create,$to_make_create);
                           foreach(@$dt)
                           {
                                $sum+=$_->[0];
                                next  if($sum<$payed_sum);
                                push @to_make_create,$_->[1];
                           }
                            
                            
                           if(@to_make_create)
                           {
                                   $to_make_create=join(',',@to_make_create);
                                   $dbh->do(qq[UPDATE documents_transactions SET dt_status='created'
                                   WHERE dt_id IN ($to_make_create) AND dt_status='processed']); 
                           } 
                                 
                                
                                
                    }elsif($tmp_sum==$payed_sum)
                    {
                           return ;

                    }elsif($tmp_sum<$payed_sum)
                    {
                          my $sum=$tmp_sum;
                          foreach(@$dt_c)  
                          {
                               $sum+=$_->[0];
                               last  if($sum>$payed_sum);
                               $dbh->do(q[UPDATE documents_transactions 
                               SET dt_status='processed'
                               WHERE dt_id=? AND dt_status='created'],undef,$_->[1]);
                          }
                            
                            

                    }
=cut


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
			$self->query->param('dr_aid',$DOCUMENTS);
		}
		##
		$self->query->param('dr_oid',$self->{user_id});
		my @of_id_=$self->query->param('dr_ofid_from');
		
		my $of_id=$dbh->selectrow_array(q[SELECT of_id FROM out_firms 
		WHERE of_id=? OR of_name=?],undef,$of_id_[0],$of_id_[1]);
		unless($of_id)
		{
			$dbh->do(q[INSERT INTO out_firms(of_name) VALUES(?)],undef,$of_id_[1]);
			$self->query->param('dr_ofid_from',$dbh->selectrow_array(q[SELECT last_insert_id() ]));

		}else
		{
			$self->query->param('dr_ofid_from',$of_id);
		}
		
	
	}




}





1;