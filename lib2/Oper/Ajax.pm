package Oper::Ajax;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
#use lib $PMS_PATH;
use POSIX;
#this  package needing the checking of all params

sub setup
{
  my $self = shift;
    
  $self->run_modes(
    'AUTOLOAD'   => 'get_account_services_percent',
    'get_money_traffic_list'=>'get_money_traffic_list',
    'change_ts_accounts_report'=>'change_ts_accounts_report',
    'change_cat_account'=>'change_cat_account',
    'ajax_close_deal'=>'ajax_close_deal',
    'ajax_del_deal'=>'ajax_del_deal',
    'get_account_services_percent' => 'get_account_services_percent',
    'get_firm_services'=>'get_firm_services',
    'search_amnt'=>'search_amnt',
    'set_col'=>'set_col',
    'set_col_all'=>'set_col_all',
    'delete_firm_req'=>'delete_firm_req',
    'back_firm_req'=>'back_firm_req',
    'ajax_exc_back'=>'ajax_exc_back',
    'delete_transfer'=>'delete_transfer',
    'del_transit'=>'del_transit',
    'del_conv'=>'del_conv',
    'send_req_next_day'=>'send_req_next_day',
    'set_col_no'=>'set_col_no',
    'make_payments'=>'make_payments',
    'delete_transfer_by_transaction'=>'delete_transfer_by_transaction',
    'search_amnt_bn'=>'search_amnt_bn',
    'get_client_oper_info_ajax'=>'get_client_oper_info_ajax',
    'confirm_pay_req'=>'confirm_pay_req',
    'cancel_pay_req'=>'cancel_pay_req',
    'delete_document_payment'=>'delete_document_payment',
    'document_change_account'=>'document_change_account',
    'document_change_account_doc'=>'document_change_account_doc',
    'ajax_deal_info'=>'ajax_deal_info',
    'ajax_deal_docs'=>'ajax_deal_docs',
    'ajax_edit_comment'=>'ajax_edit_comment',
    'ajax_del_header_rate'=>'ajax_del_header_rate',
    'ajax_show_spents'=>'ajax_show_spents',
    'ajax_reopen_doc'=>'ajax_reopen_doc',
    'send_through_localhost'=>'send_through_localhost',
    'get_last_archive_record'=>'get_last_archive_record',
    'ajax_account_info'=>'ajax_account_info'

 
  );
}
sub ajax_account_info{
    my $self=shift;
    my $aid=$self->query->param('a_id');
    my $info=$dbh->selectrow_hashref(q[SELECT * FROM accounts_view WHERE a_id=?],undef,$aid);
    my $r=$dbh->selectall_arrayref(q[SELECT 
                  fs_name as name,cs_percent  as value
                  FROM client_services,firm_services WHERE  fs_status='active'  AND cs_aid=? AND fs_id=cs_fsid],undef,$aid);
    my @res;
    foreach my $t(@$r){
        push @res,{name=>$t->[0],value=>$t->[1]};
    }
    my $tmpl=$self->load_tmpl('ajax_account_info.html');
    $self->{tpl_vars}->{services}=\@res;
    $self->{tpl_vars}->{info}=$info;
    my $output;
    $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
    return $output;

}
sub get_last_archive_record
{
    my $self=shift;
    my $fid=$self->query->param('a_id');
    my $sth=$dbh->prepare(q[SELECT 
                    ah_usd AS USD,
                    ah_eur AS EUR,
                    ah_uah AS UAH,
                    ah_ts as ts
                    FROM accounts_history 
                    WHERE ah_aid=? AND ah_status!='deleted' ORDER BY ah_id DESC LIMIT 20]);
    $sth->execute($fid);
    my @arr;
    while(my $r=$sth->fetchrow_hashref()){
        $r->{ts}=format_datetime($r->{ts});    
      push @arr,$r;
     }

    $sth->finish();
    
    my $tmpl=$self->load_tmpl('reports_archive_record.html');
    $self->{tpl_vars}->{list}=\@arr;
    $self->{tpl_vars}->{a_id}=$fid;
    my $output;
    $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
    return $output;
    

}
#this procedure only for resident documents
sub change_ts_accounts_report{
    my $self=shift;
    my $ts=$self->query->param('ts');
    my $ct_id=$self->query->param('ct_id');
    my $ct_type=$self->query->param('type');
    

    return '<root>error</root>'    if($ts!~/^\d\d\d\d-\d\d-\d\d$/);
    

    my $res=$dbh->do(qq[UPDATE accounts_reports_table SET ct_date='$ts',ts='$ts' 
    WHERE 
    ct_id=? 
    AND 
    ct_ex_comis_type=?],undef,$ct_id,$ct_type);

    return '<root></root>'    unless($res eq '1');
    return '<root>ok!</root>';
}
sub get_money_traffic_list{
    my $self=shift;
    my $id=$self->query->param('dr_aid');
    my $ct_date=$self->query->param('dr_date');
    my $ct_fid=$self->query->param('dr_fid');

    my $dr_id=$self->query->param('dr_id');
    my $firm_name=$dbh->selectrow_array(q[SELECT lcase(of_name) FROM documents_requests,out_firms WHERE dr_id=? AND dr_ofid_from=of_id],undef,$dr_id);
    $firm_name=~m/([^\n\t\ \-]+)/;
    $firm_name=lc $1;
    
    #return $firm_name;

   my $dat;

    $dat=$dbh->selectall_arrayref(qq[SELECT 
    CONCAT(MONTH(ct_date),'.',YEAR(ct_date)) as dat,
    MONTH(ct_date) as mon,
    YEAR(ct_date) as ye,
    SUM(ct_amnt) 
    FROM cashier_transactions 
    WHERE 
    ct_amnt>0 
    AND
     lcase(ct_comment) like '%$firm_name%' 
    AND
    ct_currency='UAH' 
    AND ct_status='processed'
    AND ct_aid=?
    AND ct_fid=?
    AND YEAR(ct_date)>=YEAR(?)
    GROUP BY dat ],undef,$id,$ct_fid,$ct_date);
#   return "$id,$ct_fid,$ct_date,$firm_name";

    

    my @ar;
#    shift @$dat;

    my $sum=0;
    
    my $tmpl=$self->load_tmpl('ajax_money_traffic_list.html');
    foreach(@$dat){
         $sum+=$_->[3];
         push @ar,{amnt=>format_float($_->[3]),title=>$months{$_->[1]}.' - '.$_->[2]};
     }
     push @ar,{title=>"Всего",amnt=>format_float($sum)};

     $self->{tpl_vars}->{id}=$dr_id;
     $self->{tpl_vars}->{list}=\@ar;
     my $output;
     $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
     return $output;
}

sub send_through_localhost
{
    my $self=shift;
    my $id=$self->query->param('ct_aid');
    my $own_email=$self->query->param('email');
    require LWP::UserAgent;
    my $ua = LWP::UserAgent->new;
    $ua->agent("MyApp/0.1 ");
    my $session=$self->query->cookie('session');
    my $req = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/accounts_reports.cgi');
    $req->content_type('application/x-www-form-urlencoded');
    $req->content(qq[action=filter&do=send_balance&ct_aid=$id&email=$own_email&ct_date=all_time&ajax=1&session=$session]);
    my $res = $ua->request($req);
    # Check the outcome of the response
    if ($res->is_success) {
        return   $res->content;
    }
}
sub ajax_reopen_doc
{
    my $self=shift;
    my $dr_id=$self->query->param('param');
    my $res=$dbh->do(q[UPDATE documents_requests SET dr_status='created' WHERE dr_id=?],undef,$dr_id);
    die "there is some races \n"    if($res ne '1');
    my $tid=$dbh->selectrow_array(q[SELECT dr_close_tid FROM documents_requests WHERe dr_id=?],undef,$dr_id);    
    return  "ok!"    unless($tid);
    $dbh->do(qq[UPDATE accounts_reports_table SET ct_status='deleted' WHERE ct_ex_comis_type='transaction' 
                AND  ct_id in (?,?) ],undef, $self->del_trans($tid),$tid);

    return 'ok!';



}
sub ajax_show_spents
{
    my $self=shift;
    my $id=$self->query->param('id');
    my($ts1,$ts2)=$dbh->selectrow_array(q[SELECT cr_ts,cr_last_ts
    FROM reports_without WHERE cr_id=?],undef,$id);
    return "нихрена я не нашел,что хакнуть задумали \n"   unless($ts1);
    
    my $of=$dbh->selectall_hashref(q[SELECT ow_aid 
                                                FROM 
                                                owners_without 
                                                WHERE ow_is_system='yes'],'ow_aid');

    my $aids=join(',',keys %{$of});
  

      my $ref=$dbh->selectall_hashref(qq[SELECT
                            a_name1,a_name2,t_aid1,t_aid2,t_amnt,t_comment,t_oid,o_login,t_id,t_currency
                            FROM trans_view
                            WHERE   t_ts_mysql>'$ts2' 
                            AND t_ts_mysql<'$ts1' AND t_comment not like '%exchanging%' AND t_comment not like '%Откат%'
                            AND t_aid1 IN ($aids) ],'t_id');
			    
  
     my $ref1=$dbh->selectall_hashref(qq[SELECT
                        a_name1,a_name2,t_aid1,t_aid2,t_amnt,t_comment,t_oid,o_login,t_id,t_currency
                        FROM trans_view
                        WHERE   t_ts_mysql>'$ts2' AND t_comment not like '%exchanging%' AND t_comment not like '%Откат%' 
                        AND t_ts_mysql<'$ts1' AND  t_aid2 IN ($aids) ],'t_id');
																			
																			
      
      
      my $tmpl=$self->load_tmpl('ajax_office_spents_list.html');
      my @list;
      my $tmp;
      my @keys=keys %{$ref};

      foreach(@keys)
      {
           $tmp=$ref->{$_};
           $tmp->{a_name1}=$tmp->{a_name1};
           #$tmp->{a_name2}=$tmp->{a_name2};
           $tmp->{amnt}= $tmp->{t_amnt};
           $tmp->{mines}=1;
           if( $tmp->{t_amnt}<0)
           {
	   
                $tmp->{mines}=undef;
	        $tmp->{t_amnt}=abs($tmp->{t_amnt});
                $tmp->{amnt}= $tmp->{t_amnt};
                $tmp->{a_name2}=$tmp->{a_name1};
                $tmp->{a_name1}=$tmp->{a_name2};

           }
        
	       $tmp->{t_amnt}=format_float($tmp->{t_amnt});
	       
           push @list,$ref->{$_};

      }
      
           @keys=keys %{$ref1};
	   
	   foreach(@keys){
	          $tmp=$ref1->{$_};
	          $tmp->{a_name1}=$tmp->{a_name2};
	          #$tmp->{a_name2}=$tmp->{a_name2};
	          $tmp->{amnt}= $tmp->{t_amnt};
	          if( $tmp->{t_amnt}<0)
	          {
	           $tmp->{mines}=1;
	           $tmp->{t_amnt}=abs($tmp->{t_amnt});
	           $tmp->{amnt}= $tmp->{t_amnt};
	           $tmp->{a_name2}=$tmp->{a_name1};
	           $tmp->{a_name1}=$tmp->{a_name2};
	          }
	           $tmp->{t_amnt}=format_float($tmp->{t_amnt});
	           push @list,$ref1->{$_};
	  }
	
      @list=sort { $b->{amnt} <=> $a->{amnt} } @list;	
      $self->{tpl_vars}->{id}=$id;
      $self->{tpl_vars}->{list}=\@list;
      my $output;
      $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
      return $output;

    
    



}
sub ajax_del_header_rate
{
    my $self=shift;
    my $id=$self->query->param('id');
    $dbh->do(q[DELETE FROM  header_rates  WHERE hr_id=?],undef,$id);
    return 'ok!';
}
sub ajax_edit_comment
{
    my $self=shift;
    my $id=$self->query->param('id');
    my $comment=$self->query->param('ct_comment');
    return    if(!$id||!$comment);
    require Encode;
    Encode::from_to($comment,'utf8','cp1251');
    $dbh->do(q[UPDATE cashier_transactions SET ct_comment=? WHERE ct_id=?],undef,$comment,$id);
    return 'ok!';



}

sub ajax_deal_docs
{
       my $self=shift;
       my $id=$self->query->param('id');
        $id=int($id)*1;
        
        my $proto={
        'table'=>"documents_transactions",  
        'template_prefix'=>"ajax_docs_transactions",
        'need_confirmation'=>0,
        'extra_where'=>" dt_status!='canceled' AND dt_drid=$id ",
        'page_title'=>"Заведенные документы",
        'sort'=>'dt_date DESC',
        'fields'=>[
            {
            'field'=>"dt_oid", "title"=>"Оператор", "category"=>"operators",
        
            },
            {'field'=>"dt_date", "title"=>"Дата",  'category'=>"date",},
        
        
            {
            'field'=>"dt_fid", "title"=>"Фирма", 'filter'=>"="
            , "type"=>"select",
            , "category"=>'firms'
        
            },
        
        {
                'field'=>"dt_ofid", "title"=>"Продавец", 'filter'=>"="
            , "type"=>"select",
            , "category"=>'out_firms',
        
        
        },
        {
            'field'=>"dt_aid", "title"=>"Программа", "category"=>"accounts",
            'type'=>'select',
            'titles'=>&get_accounts_simple($CLIENT_CATEGORY),
            'filter'=>'='      
            },
        
            {'field'=>"dt_amnt", "title"=>"Сумма",  'filter'=>"=",'positive'=>1},
        
            {'field'=>'dt_ts',category=>'date'},
        
            {'field'=>"dt_currency", "title"=>"Валюта", 
            'titles'=>\@currencies,
            'type'=>'select'
            },
        
        ],
            formating=>{dt_date=>'month_year'}    

        };

       return $self->proto_list($proto);
        
}
sub ajax_deal_info
{
    my $self=shift;
    my $id=$self->query->param('id');
    my $ref=$dbh->selectrow_hashref(q[SELECT
     dr_amnt,dr_fid,dr_ofid_from,of_name,
    f_name,dr_date,dr_comis,
    dr_comis*(dr_amnt/100) as dr_comis_sum,sum(dp_amnt) as dp_amnt 
    FROM 
    documents_requests,documents_payments,out_firms,firms WHERE dr_fid=f_id AND  dr_ofid_from=of_id AND  dr_id=dp_drid AND dr_id=? GROUP BY dr_id],undef,$id);
    
    my $row=$dbh->selectrow_array(q[SELECT 
    sum(dt_amnt)  
    FROM documents_transactions WHERE 
    dt_drid=? AND dt_status IN ('created','processed') GROUP BY dt_drid],undef,$id);
    $ref->{dt_amnt}=format_float($row);
    $ref->{dr_amnt}=format_float($ref->{dr_amnt});
    $ref->{dp_amnt}=format_float($ref->{dp_amnt});
    $ref->{dr_comis_sum}=format_float($ref->{dr_comis_sum});
      $ref->{dr_comis}=format_float($ref->{dr_comis});
    return qq[Сделка на сумму <strong>$ref->{dr_amnt}</strong><br/> под процент <strong>$ref->{dr_comis}\%</strong> ( $ref->{dr_comis_sum} ) <br/>оплачено  <strong>$ref->{dp_amnt}</strong> ком-ии заведен <br/> документов  на <strong>$ref->{dt_amnt}</strong> ];


}

sub document_change_account_doc
{
	my $self=shift;
	my $ct_aid=$self->query->param('ct_aid');
	my $dr_id=$self->query->param('dr_id');
    my ($status,$close_tid);
   ($dr_id,$status,$close_tid)=$dbh->selectrow_array(q[SELECT dr_id,dr_status,dr_close_tid
    FROM documents_requests WHERE dr_id=? AND dr_status IN ('created','processed')],undef,$dr_id);
    return "что-то страшное и ужасное \n" if(!$ct_aid||!$dr_id);

	my $count=$dbh->selectall_arrayref(q[SELECT  
	dp_tid,dp_ctid,dp_id FROM 
	documents_payments WHERE dp_drid=?],undef,$dr_id);
    ##im too lazy for rewriting the aglorithm
	if(@{$count}>1)
	{
        my @a;
		foreach(@$count)
		{
            if($_->[0])
			{
				
                    push @a,$_->[0];
                    push @a,$self->del_trans($_->[0]);
                    my $ref=get_transaction_info($_->[0]);

                    my $new_id=$self->add_trans(
                    {
                        t_name1 => $ct_aid,
                        t_name2 => $ref->{t_aid2},
                        t_currency => $ref->{t_currency},
                        t_amnt => $ref->{t_amnt},
                        t_comment => $ref->{t_comment},               
                        t_status=>'system',
                     });
                    
                     $dbh->do(q[UPDATE documents_payments SET dp_tid=? WHERE dp_id=?],undef,
                     $new_id,$_->[2]);
    
    


            }elsif($_->[1])
            {
                 my $ref=$dbh->selectrow_hashref(q[SELECT ct_status,ct_aid FROM cashier_transactions WHERE ct_id=? ],undef,$_->[1]);
                
                $dbh->do(q[UPDATE cashier_transactions SET  ct_aid=? WHERE ct_status='created' AND ct_id=?],undef,$ct_aid,$_->[1]);
                


            }
		}
                my $str=join(',',@a);

                $dbh->do(qq[UPDATE accounts_reports_table SET ct_status='deleted' WHERE ct_ex_comis_type='transaction' 
                AND  ct_id IN ($str) ]) if($str);

                $dbh->do(q[UPDATE documents_requests 
                SET dr_aid=? WHERE dr_id=?],undef,$ct_aid,$dr_id);

                require Documents;
                Documents::reclose_doc($self,$dr_id) if($status eq 'processed');

                $dbh->do(q[UPDATE documents_transactions 
                SET dt_aid=? WHERE dt_drid=? AND dt_status!='canceled'
                ],undef,$ct_aid,$dr_id);
	


                return 'ok';

	}
	else
	{
		$dbh->do(q[UPDATE documents_requests SET dr_aid=? WHERE dr_id=?],undef,$ct_aid,$dr_id);
		$dbh->do(q[UPDATE documents_transactions 
		SET dt_aid=? WHERE dt_drid=? AND dt_status!='canceled'],undef,$ct_aid,$dr_id);
		return "ok"
	}
	
	
	

		

}


sub document_change_account
{
	my $self=shift;
	my $ct_aid=$self->query->param('ct_aid');

	my $dt_id=$self->query->param('dt_id');
	
	my $q=$dbh->selectrow_hashref(q[SELECT * FROM documents_transactions WHERE dt_id=? 
    AND  dt_status IN ('created','processed')],undef,$dt_id);
	
# 	return "<root>ok!1</root>"  unless($q->{dt_id});
	my %q=%{$q};



	    $q{dt_aid}=$ct_aid;

		my ($id,$sum)=$dbh->selectrow_array(q[SELECT 
				dr_id,
                dr_amnt 
				FROM documents_requests 
				WHERE 
				dr_status='created' 
				AND dr_fid=? 
				AND dr_ofid_from=? 
				AND dr_aid=?
				AND dr_currency=? 
                AND dr_date=?
			],undef,$q{dt_fid},$q{dt_ofid},$q{dt_aid},'UAH',$q{dt_date});
		
		
			my $percent=$dbh->selectrow_array(q[SELECT cs_percent FROM accounts,client_services
					WHERE a_id=? AND cs_aid=a_id AND  cs_fsid=?],undef,$q{dt_aid},55);
		    
            $percent=1.2 unless($percent);

            if($q{dt_drid}&&$q{dt_infl} eq 'yes')
            {
                $dbh->do(q[UPDATE documents_requests SET dr_amnt=dr_amnt-? 
                                                          WHERE dr_id=?],undef,
                $q{dt_amnt},$q{dt_drid});
             }


            unless($id)
			{
				$dbh->do(qq[INSERT INTO documents_requests
				(dr_comis,dr_aid,dr_amnt,dr_comment,dr_fid,dr_ofid_from,dr_oid,dr_date)
				VALUES($percent,?,?,?,?,?,?,?)
				],
				undef,$q{dt_aid},$q{dt_amnt},
				$q{dt_comment},$q{dt_fid},$q{dt_ofid},$self->{user_id},$q{dt_date});
				my $doc_id=$dbh->selectrow_array(q[SELECT last_insert_id()]);
				$dbh->do(qq[INSERT INTO documents_payments(dp_ctid,dp_drid,dp_tid) VALUES(?,?,?)],undef,0,$doc_id,0);
				
				$dbh->do(
				qq[INSERT INTO documents_requests_logs
				(dr_comis,dr_aid,dr_amnt,dr_comment,dr_fid,dr_ofid_from,dr_oid,dr_date)
				VALUES($percent,?,?,?,?,?,?,?)
				],undef,$q{dt_aid},$q{dt_amnt},$q{dt_comment},$q{dt_fid},$q{dt_ofid},$self->{user_id},$q{dt_date});
				
				$dbh->do(q[UPDATE documents_transactions SET dt_aid=?,dt_drid=?,dt_infl='yes'
				WHERE  dt_id=? AND dt_status='created' ],undef,$q{dt_aid},$doc_id,$dt_id);
				


			
			}else
			{
	
				my $sum_fact=$dbh->selectrow_array(q[SELECT sum(dt_amnt) 
				FROM 
				documents_transactions 
				WHERE dt_drid=?  
				AND (dt_status='created' 
				OR  dt_status='processed')
				GROUP BY dt_drid],undef,$id);
			
								
				$sum_fact+=$q{dt_amnt};

				
				my $infl='no';
				my $status='created';
				
				
				my $payd_sum=$dbh->selectrow_array(q[SELECT  
                dr_amnt*(sum(t_amnt)/(dr_comis*(dr_amnt/100))) as payd_sum 
								     FROM 
								     documents_payments,transactions,documents_requests
								     WHERE dp_tid=t_id 
								  AND dr_id=dp_drid AND dr_id=? GROUP BY dr_id],undef,$id);

				
				$status='processed' if($payd_sum>=$sum_fact);
				
				
				if($sum_fact>$sum)
				{
					$dbh->do(q[UPDATE documents_requests SET dr_amnt=?  WHERE dr_id=?],undef,$sum_fact,$id);
					$infl='yes';

				}
                


				
				$dbh->do(qq[UPDATE documents_transactions SET dt_aid=?,dt_drid=?,dt_infl='$infl',dt_status='$status' 
				WHERE dt_id=? AND dt_status='created' ],undef,$q{dt_aid},$id,$dt_id);
			
			
			}	


	return "<root>ok!</root>";


}
sub  delete_document_payment
{

	my $self=shift;
	my $a_id=shift || $self->query->param('id');
    
	my ($id,$amnt,$ctid,$drid)=$dbh->selectrow_array(q[
                SELECT dp_tid,dr_amnt,dp_ctid,dr_id
				FROM documents_payments,documents_requests WHERE dp_id=? 
				AND dr_id=dp_drid ],undef,$a_id);

	###very 
	my $res='1';
	$res=$dbh->do(q[DELETE  FROM documents_payments WHERE dp_id=?],undef,$a_id) if($amnt>=0);
	    if($amnt<0||$id<0||$res ne '1')
	        {
		        die "fuck of!!delete_document_payment ";
			
		}
	
	my $ref=$dbh->selectrow_hashref(q[SELECT t_id,t_aid2,t_aid1,t_currency,t_amnt,t_comment FROM 
	transactions  WHERE 1 AND t_id=?],undef,$id);
	
	my $tid = $self->add_trans(
	{
      		t_name1 =>$ref->{t_aid2},
    		t_name2 => $ref->{t_aid1},
      		t_currency => $ref->{t_currency},
      		t_amnt =>$ref->{t_amnt} ,
      		t_comment =>" Удаление оплаты ".$ref->{t_comment},
		
     
     });
	
	my $payd_sum=$dbh->selectrow_array(q[SELECT  dr_amnt*(sum(t_amnt)/(dr_comis*(dr_amnt/100))) as payd_sum 
								     FROM 
								     documents_payments,transactions,documents_requests
								     WHERE 
								     dp_tid=t_id  
								     AND 
								     dr_status='created'
								     AND 
								     dr_id=dp_drid AND dr_id=? GROUP BY dr_id],undef,$drid);

	
	


	my $dts=$dbh->selectall_arrayref(q[SELECT 
	dt_amnt,
	dt_id 
	FROM documents_transactions WHERE dt_drid=? AND dt_status='processed' ORDER BY dt_id ],undef,$drid);
	my $sum=0;
	my $str;

	foreach(@$dts)
	{
		$sum+=$_->[0];
		if($sum>$payd_sum)
		{
			$str.="$_->[1],";
			next;
		}
	}	
	chop($str);
	$dbh->do(qq[UPDATE documents_transactions SET dt_status='created' WHERE dt_id IN ($str) ]) if($str);

	$dbh->do(qq[
	INSERT  INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
		select 
		t_id,
		`transactions`.`t_aid2` AS `t_aid2`,
		`transactions`.`t_comment` AS	`t_comment`,
		`operators`.`o_id` AS `o_id`,`operators`.`o_login` AS `o_login`,
		`transactions`.`t_aid1` AS 
		`t_aid1`,`accounts`.`a_name` AS `a_name`,`transactions`.`t_amnt` AS 
		`t_amnt`,`transactions`.`t_currency` 
		 AS `t_currency`,
		0 AS `0`,
		`transactions`.`t_amnt` AS `t_amnt`,
		0 AS `0`,
		0 AS `0`,
		cast(`transactions`.`t_ts` as date) AS `t_ts`,
		`transactions`.`t_currency` AS `t_currency`,
		0 AS `0`,
		0 AS `0`,'transaction' AS `transaction`,
		`transactions`.`t_ts` AS `ts`,
		'0000-00-00 00:00:00',
		'deleted',
		16777215  
		from ((`transactions` join `operators`) join `accounts`) 
		WHERE (1 and (`operators`.`o_id` = `transactions`.`t_oid`) 
		and (((`transactions`.`t_aid1` > 1) and (`transactions`.`t_aid2` > 1)) 
		) 
		and (`accounts`.`a_id` = `transactions`.`t_aid1`))
		AND t_id=? LIMIT 1
	
	],undef,$tid);

	$dbh->do(qq[
		INSERT  INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
		select 
		t_id,
		`transactions`.`t_aid1` AS `t_aid1`,
		`transactions`.`t_comment` AS `t_comment`,
		`operators`.`o_id` AS `o_id`,
		`operators`.`o_login` AS `o_login`,
		`transactions`.`t_aid2` AS `t_aid2`,
		`accounts`.`a_name` AS `a_name`,
		-(`transactions`.`t_amnt`) AS `-t_amnt`,
		`transactions`.`t_currency` AS `t_currency`,
		0 AS `0`,
		-(`transactions`.`t_amnt`) AS `-t_amnt`,
		0 AS `0`,0 AS `0`,
		cast(`transactions`.`t_ts` as date) AS `t_ts`,
		`transactions`.`t_currency` AS `t_currency`,0 AS `0`,0 AS `0`,
		'transaction' AS `transaction`,
		`transactions`.`t_ts` AS `ts`,
		'0000-00-00 00:00:00',
		'deleted',
		16777215  
		from ((`transactions` join `operators`) join `accounts`) 
		where
		 (1 and (`operators`.`o_id` = `transactions`.`t_oid`) 
		and (((`transactions`.`t_aid1` > 1) 
		and (`transactions`.`t_aid2` > 1))) and (`accounts`.`a_id` = 
		`transactions`.`t_aid2`))
		AND t_id=? LIMIT 1
	
	],undef,$tid);

	$dbh->do(q[UPDATE 
		accounts_reports_table SET ct_status='deleted' 
		WHERE 
		ct_id=? AND ct_ex_comis_type='transaction'],undef,$ref->{t_id});

	$dbh->do(q[UPDATE 
		accounts_transfers 
		SET at_tid_back=?,at_status='deleted'
		WHERE at_id=?],undef,$tid,$id);
	$dbh->do(
		q[UPDATE 
		transactions 
		SET t_status='no' 
		WHERE t_id=? ],undef,$tid);

  	return  "<root>ok!</root>";

}



sub ajax_close_deal
{
		my $self=shift;
		my $param=$self->query->param('param') || shift;
	    my $res=$dbh->do(q[UPDATE documents_requests 
        SET dr_status='processed' WHERE dr_id=? AND dr_status='created'],undef,$param);
        return 'ok!1' unless($res eq '1');
            


        my $ref=$dbh->selectrow_hashref(q[
        SELECT
        dr_aid,
        dr_amnt,
        dr_currency,
        sum(dp_amnt) as sum_amnt 
        FROM documents_requests,documents_payments 
        WHERE dp_drid=dr_id AND dp_tid!=0
        AND dr_id=? AND dr_status='processed' GROUP BY dr_id],undef,$param);
        
        return  'ok!2!ajax_close_deal'    if(!$ref||$ref->{dr_amnt}<0);

       $param=~s/["'\\]//g;

        my $pays=$dbh->selectall_hashref(qq[SELECT dp_tid FROM documents_requests,documents_payments 
        WHERE dp_drid=dr_id AND   dr_id=$param  AND 1 AND dp_tid!=0],'dp_tid');
        
        my $str=join(q[,],keys %$pays);
        
          my $tid = $self->add_trans(
            {
                t_name1 =>$DOCUMENTS,
                t_name2 =>$ref->{dr_aid},
                t_currency => $ref->{dr_currency},
                t_amnt =>$ref->{sum_amnt},
                t_comment =>" закрытие сделки   #$param",
                t_status =>'system'
         });


        $dbh->do(qq[UPDATE 
        accounts_reports_table 
        SET col_status='yes' 
        WHERE ct_id IN ($str,$tid) AND ct_ex_comis_type='transaction']);

         $dbh->do(q[UPDATE documents_requests SET dr_close_tid=? WHERE dr_id=?],undef,$tid,$param);

         return 'ok!';

        
#         $dbh->do(qq[UPDATE 
#        accounts_reports_table 
#        SET ct_status='deleted' 
#        WHERE ct_id IN ($str) AND ct_ex_comis_type='transaction']);

        
        return 'ok!';
}
sub ajax_del_deal
{
		my $self=shift;
		my $params=$self->query->param('id');
	
        my ($sum,$id)=$dbh->selectrow_array(q[SELECT dr_amnt,dr_id FROM documents_requests 
		 WHERE 1
	     AND  dr_id=?
		 AND dr_status='created' ],undef,$params);

		my $res=$dbh->do(q[UPDATE documents_requests SET 
	    dr_status='deleted' WHERE dr_id=? AND dr_status='created'] ,undef,$params);
		
		die 'ok!1ajax_del_deal' if($res ne '1');		
		
		$dbh->do(q[UPDATE documents_transactions SET 
        dt_drid=NULL,dt_status='created',dt_infl='yes' 
        WHERE dt_drid=? AND dt_status IN ('created','processed')],undef,$id);


		 my $ref=$dbh->selectall_arrayref(q[SELECT dp_tid,
		 dp_id,dp_ctid FROM  
		 documents_requests,documents_payments
		 WHERE 
        dr_id=dp_drid
		 AND dr_id=? 
		 AND dp_tid!=0 
		 AND dr_status='deleted' ],undef,$params);
		
		my $str2_del;
		foreach(@$ref)	
		{
			$str2_del.="$_->[2],";
			$self->query->param('id',$_->[1]);
			$self->delete_document_payment();
			
		}
		chop($str2_del);
		$dbh->do(qq[DELETE FROM cashier_transactions  WHERE ct_id IN($str2_del) ]) if($sum<0);
	
    return 'ok!2';

}
sub cancel_pay_req
{
	my $self=shift;
	$dbh->do(q[UPDATE cashier_transactions SET col_status='no',col_oid=? 
	WHERE ct_id=? 
	AND ct_status='created'],undef,$self->{user_id},$self->query->param('id'));
	return 'ok!';
}
sub confirm_pay_req
{
	my $self=shift;
	$dbh->do(q[UPDATE cashier_transactions SET col_status='yes',col_oid=? WHERE ct_id=? 
	AND ct_status='created'],undef,$self->{user_id},$self->query->param('id'));
	return 'ok!';
}
sub change_cat_account
{
	my $self=shift;
	my $fid=$self->query->param('ct_aid');
	my $ac_id=$self->query->param('ac_id');
	$dbh->do(q[UPDATE accounts SET a_acid=? WHERe a_id=?],undef,$ac_id,$fid);
	return 'ok!';

}
sub get_client_oper_info_ajax
{
	my $self=shift;
	my $fid=$self->query->param('ct_aid');
 	my $ct_ts1=$self->query->param('ct_date_from');	
	my $ct_ts2=$self->query->param('ct_date_to');

	my $operations_info=$dbh->prepare(qq[
	SELECT sum(ct_amnt) as cash_in_uah,0,0 FROM cashier_transactions WHERE ct_status='processed' 
		AND ct_fid=-1 AND ct_amnt>0 AND DATE(ct_ts2)>='$ct_ts1' AND DATE(ct_ts2)<='$ct_ts2' 
	  AND ct_aid=? AND ct_currency='UAH' UNION ALL 
	SELECT sum(ct_amnt) as cash_out_uah,0,0 FROM cashier_transactions WHERE ct_status='processed' 
	AND ct_fid=-1 AND ct_amnt<0  AND ct_aid=? AND DATE(ct_ts2)>='$ct_ts1' 
	AND DATE(ct_ts2)<='$ct_ts2' AND ct_currency='UAH' UNION ALL
	SELECT sum(ct_amnt) as cash_in_usd,0,0 FROM cashier_transactions WHERE ct_status='processed' 
		AND ct_fid=-1 AND ct_amnt>0  AND   DATE(ct_ts2)>='$ct_ts1' 
	AND DATE(ct_ts2)<='$ct_ts2' AND ct_aid=? AND ct_currency='USD' UNION ALL 
	SELECT sum(ct_amnt) as cash_out_usd,0,0  FROM cashier_transactions WHERE ct_status='processed' 
		AND ct_fid=-1 AND ct_amnt<0 AND DATE(ct_ts2)>='$ct_ts1' 
	AND DATE(ct_ts2)<='$ct_ts2'  AND ct_aid=? AND ct_currency='USD' UNION ALL
	SELECT sum(ct_amnt) as cash_in_eur,0,0 FROM cashier_transactions WHERE ct_status='processed' 
		AND ct_fid=-1 AND ct_amnt>0 
		AND DATE(ct_ts2)>='$ct_ts1' AND DATE(ct_ts2)<='$ct_ts2'  
		AND ct_aid=? AND ct_currency='EUR' UNION ALL 
	SELECT sum(ct_amnt) as cash_out_eur,0,0 FROM cashier_transactions WHERE ct_status='processed' 
		AND ct_fid=-1 AND ct_amnt<0 
	AND DATE(ct_ts2)>='$ct_ts1' AND DATE(ct_ts2)<='$ct_ts2' AND ct_aid=?  AND ct_currency='EUR' 
	]);



	$operations_info->execute($fid,$fid,$fid,$fid,$fid,$fid);
	my $id={
		1=>'cash_in_uah',
		2=>'cash_out_uah',
		3=>'cash_in_usd',
		4=>'cash_out_usd',
		5=>'cash_in_eur',
		6=>'cash_out_eur',
		7=>'bn_in_uah',
		8=>'bn_out_uah',
		9=>'bn_in_usd',
		10=>'bn_out_usd',
		11=>'bn_in_eur',
		12=>'bn_out_eur',
	};
	
	my $i=1;
	my $info={};
	while(my $r=$operations_info->fetchrow_arrayref())
	{
		$info->{$id->{$i}}=format_float(abs($r->[0]));
		$info->{$id->{$i}.'_com'}=format_float((abs($r->[1])));
		$i++;	
	}
	
	my $r=$dbh->selectrow_arrayref(qq[
	SELECT sum(ct_amnt) as bn_in_uah,
	sum(if(
	`cashier_transactions`.`ct_eid` is not NULL AND `cashier_transactions`.`ct_tid2_comis` is NULL,
	((1 / `exchange_view`.`e_rate`) * 
	((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_amnt`) - 
	(`cashier_transactions`.`ct_amnt` * 
	(`exchange_view`.`e_rate` + 
	((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
	((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100)
	)) as bn_in_uah_com  ,0
	FROM cashier_transactions   LEFT JOIN exchange_view ON ct_eid=e_id WHERE ct_status='processed'
	AND ct_fid>0 AND ct_amnt>0 AND DATE(ct_ts2)>='$ct_ts1' 
	AND DATE(ct_ts2)<='$ct_ts2' AND   ct_aid=? AND ct_currency='UAH'  GROUP BY ct_aid],undef,$fid);
	$info->{$id->{$i}}=format_float(abs($r->[0]));
	$info->{$id->{$i}.'_com'}=format_float((abs($r->[1])));
	$i++;
	
	$r=$dbh->selectrow_arrayref(qq[
	SELECT sum(ct_amnt) as bn_out_uah,sum(if(
	`cashier_transactions`.`ct_eid` is not NULL AND `cashier_transactions`.`ct_tid2_comis` is NULL,
	((1 / `exchange_view`.`e_rate`) * 
	((`exchange_view`.`e_rate` * abs(`cashier_transactions`.`ct_amnt`)) - 
	(abs(`cashier_transactions`.`ct_amnt`) * 
	(`exchange_view`.`e_rate` + 
	((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
	((abs(`cashier_transactions`.`ct_amnt`) * `cashier_transactions`.`ct_comis_percent`) / 100)
	)) as bn_out_uah_com,0  FROM cashier_transactions 
	 LEFT JOIN exchange_view ON ct_eid=e_id WHERE ct_status='processed' 
	AND  ct_fid>0 AND ct_amnt<0 AND DATE(ct_ts2)>='$ct_ts1' AND DATE(ct_ts2)<='$ct_ts2'  
	AND ct_aid=?  AND ct_currency='UAH'  
	GROUP BY ct_aid],undef,$fid);
	 $info->{$id->{$i}}=format_float(abs($r->[0]));
	$info->{$id->{$i}.'_com'}=format_float((abs($r->[1])));
	$i++;
	$r=$dbh->selectrow_arrayref(qq[
	SELECT sum(ct_amnt) as bn_in_usd,sum(if(
	`cashier_transactions`.`ct_eid` is not NULL AND `cashier_transactions`.`ct_tid2_comis` is NULL,
	((1 / `exchange_view`.`e_rate`) * 
	((`exchange_view`.`e_rate` * abs(`cashier_transactions`.`ct_amnt`)) - 
	(abs(`cashier_transactions`.`ct_amnt`) * 
	(`exchange_view`.`e_rate` + 
	((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
	((abs(`cashier_transactions`.`ct_amnt`) * `cashier_transactions`.`ct_comis_percent`) / 100)
 	)) as  bn_in_usd_com,0   FROM cashier_transactions  
	LEFT JOIN exchange_view ON ct_eid=e_id WHERE ct_status='processed' 
		AND  ct_fid>0 AND ct_amnt>0  AND ct_aid=? AND ct_currency='USD' 
		AND DATE(ct_ts2)>='$ct_ts1' AND DATE(ct_ts2)<='$ct_ts2'
	 GROUP BY ct_aid ],undef,$fid);
	$info->{$id->{$i}}=format_float(abs($r->[0]));
	$info->{$id->{$i}.'_com'}=format_float((abs($r->[1])));
	$i++;
	$r=$dbh->selectrow_arrayref(qq[ 
	SELECT sum(ct_amnt) as bn_out_usd,sum(if(
	`cashier_transactions`.`ct_eid` is not NULL AND `cashier_transactions`.`ct_tid2_comis` is NULL,
	((1 / `exchange_view`.`e_rate`) * 
	((`exchange_view`.`e_rate` * abs(`cashier_transactions`.`ct_amnt`)) - 
	(abs(`cashier_transactions`.`ct_amnt`) * 
	(`exchange_view`.`e_rate` + 
	((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
	((abs(`cashier_transactions`.`ct_amnt`) * `cashier_transactions`.`ct_comis_percent`) / 100)
	)) as  bn_out_usd_com,0 FROM cashier_transactions
	  LEFT JOIN exchange_view ON ct_eid=e_id WHERE ct_status='processed' 
		AND  ct_fid>0 AND ct_amnt<0   AND ct_aid=? AND ct_currency='USD' 
		AND DATE(ct_ts2)>='$ct_ts1' AND DATE(ct_ts2)<='$ct_ts2'
	GROUP BY ct_aid ],undef,$fid);
$info->{$id->{$i}}=format_float(abs($r->[0]));
	$info->{$id->{$i}.'_com'}=format_float((abs($r->[1])));
	$i++;
	$r=$dbh->selectrow_arrayref(qq[
	SELECT sum(ct_amnt) as bn_in_eur,sum(if(
	`cashier_transactions`.`ct_eid` is not NULL AND `cashier_transactions`.`ct_tid2_comis` is NULL,
	((1 / `exchange_view`.`e_rate`) * 
	((`exchange_view`.`e_rate` * abs(`cashier_transactions`.`ct_amnt`)) - 
	(abs(`cashier_transactions`.`ct_amnt`) * 
	(`exchange_view`.`e_rate` + 
	((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
	((abs(`cashier_transactions`.`ct_amnt`) * `cashier_transactions`.`ct_comis_percent`) / 100)
	)) as   bn_in_eur_com,0 FROM cashier_transactions
	  LEFT JOIN exchange_view ON ct_eid=e_id WHERE ct_status='processed' 
	AND  ct_fid>0 AND ct_amnt>0   AND ct_aid=? AND ct_currency='EUR'
	AND DATE(ct_ts2)>='$ct_ts1' AND DATE(ct_ts2)<='$ct_ts2'
	GROUP BY ct_aid],undef,$fid);
	$info->{$id->{$i}}=format_float(abs($r->[0]));
	$info->{$id->{$i}.'_com'}=format_float((abs($r->[1])));
	$i++;
	$r=$dbh->selectrow_arrayref(qq[SELECT sum(ct_amnt) as bn_out_eur,sum(if(
	`cashier_transactions`.`ct_eid` is not NULL AND `cashier_transactions`.`ct_tid2_comis` is NULL,
	((1 / `exchange_view`.`e_rate`) * 
	((`exchange_view`.`e_rate` * abs(`cashier_transactions`.`ct_amnt`)) - 
	(abs(`cashier_transactions`.`ct_amnt`) * 
	(`exchange_view`.`e_rate` + 
	((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
	((abs(`cashier_transactions`.`ct_amnt`) * `cashier_transactions`.`ct_comis_percent`) / 100)
	)) as bn_out_eur_com,0 FROM cashier_transactions 
	LEFT JOIN exchange_view ON ct_eid=e_id WHERE ct_status='processed' 
	AND DATE(ct_ts2)>='$ct_ts1' AND DATE(ct_ts2)<='$ct_ts2'
	AND  ct_fid>0 AND ct_amnt<0  AND ct_aid=?  AND ct_currency='EUR'  
	GROUP BY ct_aid],undef,$fid);
	$info->{$id->{$i}}=format_float(abs($r->[0]));
	$info->{$id->{$i}.'_com'}=format_float((abs($r->[1])));
	$i++;





	
	$operations_info->finish();
	my $str='<root>';
	map {$str.="<$_>$info->{$_}</$_>\n" } sort keys %{$info};
	$str.='</root>';
	return $str;

}	


sub search_amnt_bn
{
	my $self=shift;
	my %params;
	map{$params{$_}=$self->query->param($_) } $self->query->param();
	if($params{ct_amnt})
   	{
		$params{ct_amnt}=~s/\n"'\t\\//g;
		$params{ct_amnt}=abs($params{ct_amnt});
		
		my $per=$SEARCH_DISP_FIRM*($params{ct_amnt}/100);

		my $txt="<root>";
		my $ref=$dbh->selectall_arrayref(qq[
		SELECT 
		DATE_FORMAT(ct_date,'%d.%c.%Y'),
		ct_amnt,
		ct_currency,
		ct_comment,
		ct_status,
		a_name,
		f_name 
		FROM 
		firms,cashier_transactions LEFT JOIN accounts ON ct_aid=a_id
		WHERE 	
		f_id=ct_fid
		AND ct_fid>0
		AND ct_status not in ('deleted','transit')
		AND  abs(ct_amnt)<=($params{ct_amnt}+$per)
		AND  abs(ct_amnt)>=($params{ct_amnt}-$per)   
		AND  ( if(ct_ts2 IS NOT NULL, date_sub(current_timestamp,interval $SEARCH_DAYS_FIRM day)<ct_ts2,1) 
		OR   date_sub(current_timestamp,interval $SEARCH_DAYS_FIRM day)<ct_ts  
		) AND ct_currency=?
	  	
 		],undef,$params{ct_currency}
		);
		
		my %statuses=(
			canceled=>'Отменена',
			created=>'Создана',
			returned=>'Возвращена',
			processed=>'Проведена',

		);

		foreach(@$ref)
		{
			$_->[0]=~s/[&]/&amp;/g;
			$_->[0]=~s/[<]/&lt;/g;
			$_->[0]=~s/[>]/&gt;/g;
			$_->[0]=~s/[']/&apos;/g;
			$_->[0]=~s/["]/&quot;/g;

			$_->[5]=~s/[&]/&amp;/g;
			$_->[5]=~s/[<]/&lt;/g;
			$_->[5]=~s/[>]/&gt;/g;
			$_->[5]=~s/[']/&apos;/g;
			$_->[5]=~s/["]/&quot;/g;

			$_->[6]=~s/[&]/&amp;/g;
			$_->[6]=~s/[<]/&lt;/g;
			$_->[6]=~s/[>]/&gt;/g;
			$_->[6]=~s/[']/&apos;/g;
			$_->[6]=~s/["]/&quot;/g;
			$_->[4]=$statuses{$_->[4]};
			$txt.='<record>';
			$txt.="$_->[0]: $_->[4] ";
			$txt.="$_->[1] ";
			$txt.=$conv_currency->{$_->[2]};
			$txt.=", назначение :  $_->[3]  ";
			$txt.='</record>';
			$txt.="<user>$_->[5]</user>";		
			$txt.="<firm>$_->[6]</firm>";
			
		}
		return $txt.'</root>';
	}	
   	return  "<root></root>"; 

}

sub make_payments
{
	my $self=shift;
	my %params;
	map{$params{$_}=$self->query->param($_) } $self->query->param();
	
	
	$params{f_name}=$dbh->selectrow_array(q[SELECT f_name FROM firms 
	WHERe f_status='active' AND f_id=?],undef,$params{id});
	unless($params{f_name})
	{
		return "there isn't such firm \n";
	
	}
	if(!$params{date}||$params{date}!~/\d\d\d\d\-\d\d\-\d\d/||!$params{currency}||!$avail_currency_firms->{$params{currency}}||$params{amnt}<=0)
	{
		return "there is a wrong sum or date $params{currency} $params{amnt} \n";

	}
=pod
	return "there is payments"	if($dbh->selectrow_array(q[SELECT nrp_id FROM 
		non_resident_payments 
		WHERE 
		nrp_fid=? 
		AND nrp_currency=? 
		AND nrp_date=?],undef,$params{id},$params{currency},$params{date}));
=cut

	my $comment="Платежи  за операции  за дату $params{date} фирмы $params{f_name}";

		my  $tid = $self->add_trans({
        				t_name1 => $VAL_PAYMENTS,
					t_name2 => $firms_id,
	    				t_currency => $params{currency},
	    				t_amnt => $params{amnt},
	   		 		t_comment =>$comment ,
		});
		
		my $payments_number_param={
			USD=>'pay_dialog_num_usd',
			EUR=>'pay_dialog_num_eur'	
			
		};
	
		my $number_of_payms=$params{ $payments_number_param->{ $params{currency} } };


		my $currency=lc($params{currency});
		

		$dbh->do("UPDATE firms  SET f_$currency=f_$currency-?  WHERE f_id=?",
					          undef,abs($params{amnt}),$params{id});

		$dbh->do(qq[INSERT  INTO
		 cashier_transactions(ct_aid,ct_amnt,ct_fid,ct_currency,ct_status,ct_comment,ct_oid,
		ct_oid2,ct_date,ct_tid2,ct_ts2,ct_ts)
		VALUES(?,?,?,?,?,?,?,?,?,?,current_timestamp,current_timestamp)
		 ],undef,$VAL_PAYMENTS,-1*abs($params{amnt}),$params{id},$params{currency},'processed',$comment,$self->{user_id},$self->{user_id},
		$params{date},$tid);
		
		my $id2=$dbh->selectrow_array(q[SELECT last_insert_id()]);
	
		$dbh->do(qq[INSERT  $SQL_DELAYED INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
		select `cashier_transactions`.`ct_id` AS `ct_id`,`cashier_transactions`.`ct_aid` AS `ct_aid`,
		`cashier_transactions`.`ct_comment` AS `ct_comment`,
		`cashier_transactions`.`ct_oid` AS `ct_oid`,
		`operators`.`o_login` AS `o_login`,
		`firms`.`f_id` AS `ct_fid`,
		`firms`.`f_name` AS `f_name`,
		`cashier_transactions`.`ct_amnt` AS `ct_amnt`,
		`cashier_transactions`.`ct_currency` AS `ct_currency`,
		if((`cashier_transactions`.`ct_eid` is not null),
		if((`cashier_transactions`.`ct_ex_comis_type` = _cp1251'in_rate'),
		((1 / `exchange_view`.`e_rate`) * ((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_amnt`) - 
		(`cashier_transactions`.`ct_amnt` * (`exchange_view`.`e_rate` + 
		((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
		((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100)),
		((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100)) AS `comission`,
		if((`cashier_transactions`.`ct_eid` is not null),
		`exchange_view`.`e_amnt1`,(`cashier_transactions`.`ct_amnt` - 
		((`cashier_transactions`.`ct_comis_percent` * abs(`cashier_transactions`.`ct_amnt`)) / 100))) AS `result_amnt`,
		`cashier_transactions`.`ct_comis_percent` AS `ct_comis_percent`,
		(-(1) * `cashier_transactions`.`ct_ext_commission`) AS `ct_ext_commission`,
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
		(((`cashier_transactions` left join `exchange_view` on((`exchange_view`.`e_id` = `cashier_transactions`.`ct_eid`))) 
		left join `firms` on((`cashier_transactions`.`ct_fid` = `firms`.`f_id`))) 
		left join `operators` on((`cashier_transactions`.`ct_oid` = `operators`.`o_id`))) 
		where ((`cashier_transactions`.`ct_amnt` < 0) 
		and (`cashier_transactions`.`ct_status` in (_cp1251'processed'))) 
		AND ct_id=? LIMIT 1],undef,$id2);	
		
		$dbh->do(qq[INSERT $SQL_DELAYED
		INTO non_resident_payments(nrp_fid,nrp_currency,nrp_date,nrp_ctid,nrp_number) 
		VALUES(?,?,?,?,?)
		],undef,$params{id},$params{currency},$params{date},$id2,$number_of_payms+1);
		my $id3=$dbh->selectrow_array(q[SELECT last_insert_id()]);
		return qq[$id3];
}
sub del_transit
{
	my $self=shift;
		
	my $id1=$self->query->param('ct_id1');
	my $id2=$self->query->param('ct_id2');
	
	my $params=$dbh->selectrow_hashref(q[SELECT 
	abs(amnt) as amnt,currency,f_id1,f_id2 
	FROM transit_view
	WHERE ct_id1=? AND ct_id2=? AND f_id1>0 AND f_id2>0],undef,$id1,$id2);
	
	##actual problem of request's races
	unless($params->{amnt})	
	{
					return '<root>error!missing such id !</root>';

	}else
	{
		
	    my $res=$dbh->do(q[DELETE FROM 	firms_transit WHERE  ft_ctid1=? AND ft_ctid2=?],undef,$id1,$id2);
	    if($res ne '1')
	    {
			return '<root>error!missing such id !</root>';

	
	    }
	}

	my $_POST={};
	$_POST->{t_oid}=$self->{user_id};
	$_POST->{f_id1}=$params->{f_id2};
	$_POST->{f_id2}=$params->{f_id1};
	$_POST->{currency}=$params->{currency};
	$_POST->{amnt}=$params->{amnt};
        $_POST->{user_id}=$self->{user_id};
        $_POST->{comment}="Удаление транзита  $id1$id2";
	my ($b_id1,$b_id2)=$self->add_trans_firm($_POST);
	
	$dbh->do(qq[UPDATE  cashier_transactions SET ct_status='deleted' WHERE ct_status='transit' AND ct_id IN ($b_id1,$b_id2,$id1,$id2)]);
	
	$dbh->do(qq[DELETE FROM firms_transit WHERE ft_ctid1=$b_id1 AND  ft_ctid2=$b_id2]);
	return '<root>ok!</root>';
}
sub del_conv
{
	
	my $self=shift;
	my $id=$self->query->param('id');
	my $ref=$dbh->selectrow_hashref(q[select * FROM firms_exchange WHERE fe_id=?],undef,$id);
	
	unless($ref->{fe_id})
	{
					return '<root>error!missing such id !</root>';

	}
	my $str="($ref->{fe_ctid1_in},$ref->{fe_ctid2_in},$ref->{fe_ctid1_out},$ref->{fe_ctid2_out})";
	
	my $res=$dbh->do(qq[UPDATE 
	cashier_transactions SET ct_status='processing' WHERE ct_id IN 
	$str AND ct_status='transit'
	]);
	
	if($res ne 4)
	{
			return '<root>error!missing such id !</root>';
	}
	
	my $ref1=$dbh->selectrow_hashref(
		q[SELECT * FROM cashier_transactions WHERE ct_id=?],
		undef,$ref->{fe_ctid1_in}
	);
	
	my ($t_in1,$t_in2)=$self->add_trans_firm(
				{
					user_id=>$self->{user_id},
					o_id=>$self->{user_id},
					amnt=>-1*$ref1->{ct_amnt},
					currency=>$ref1->{ct_currency},
					f_id1=>$FIRMS_CONV,
					f_id2=>$ref1->{ct_fid},
					comment=>"Удаление конвертации :$ref->{ct_comment}",

				}
				);

	my $ref2=$dbh->selectrow_hashref
	(
		q[SELECT * FROM cashier_transactions WHERE ct_id=?],
		undef,$ref->{fe_ctid2_out}
	);

	my ($t_out1,$t_out2)=$self->add_trans_firm(
				{
					user_id=>$self->{user_id},
					o_id=>$self->{user_id},
					amnt=>$ref2->{ct_amnt},
					currency=>$ref2->{ct_currency},
					f_id1=>$ref2->{ct_fid},
					f_id2=>$FIRMS_CONV ,
					#date=>$hash{fe_date},
					comment=>"Удаление конвертации  :$ref->{ct_comment}",

				}
				);
	
		

	$res=$dbh->do(qq[DELETE FROM 
	cashier_transactions  WHERE ct_id IN 
	$str AND ct_status='processing'
	]);
	
	
	###there we must to check this or fix some
	$res=$dbh->do(qq[DELETE FROM 
	cashier_transactions  WHERE ct_id IN 
	($t_out1,$t_out2,$t_in1,$t_in2) AND ct_status='transit'
	]);
	return '<root>ok!</root>';
   

}

sub send_req_next_day
{
	my $self=shift;
	my $id=$self->query->param('id');
	$dbh->do(q[UPDATE cashier_transactions SET ct_date=date_add(ct_date,interval 1 day) WHERE 
	ct_id=? AND ct_status='created' AND ct_req='yes'],undef,$id);
	return '<root> ok !</root>'


}

sub ajax_exc_back
{
	my $self=shift;
	my $id=$self->query->param('id');
	
### fixed
##such alorithm used in order to avoid races
	my $mutex=$dbh->do(q[UPDATE exchange SET e_status='deleted' 
	WHERE e_status='processed' AND
	  e_type!='auto' AND e_id=?],undef,$id);
	if($mutex ne '1')
	{
			return '<root>error!missing such id !</root>';
	}

 #e_status='deleted'
	my $ref=$dbh->selectrow_hashref(q[SELECT * FROM exchange_view 
	WHERE e_status='deleted' AND 
	  e_type!='auto' AND e_id=?],undef,$id);
			$ref->{e_rate}=pow($ref->{e_rate},-1) if($ref->{e_currency2} eq $ref->{e_currency1});
	$dbh->do(q[UPDATE accounts_reports_table SET ct_status='deleted' WHERE ct_ex_comis_type='simple' AND ct_id=?],undef,$id);
			my $ct_eid=$self->add_exc(
			{
			
				type=>$ref->{e_type},
				rate=>pow($ref->{e_rate},$RATE_FORMS{$ref->{e_currency1}}->{$ref->{e_currency2}}),
				e_comment=>qq[Откат обмена  #$ref->{e_id}],
				e_currency1=>$ref->{e_currency2},
				e_currency2=>$ref->{e_currency1},
				e_amnt1=>$ref->{e_amnt2},
				a_id=>$ref->{a_id},
			}
				);
	
	$dbh->do(q[UPDATE accounts_reports_table SET ct_status='deleted' WHERE ct_id=? AND ct_ex_comis_type='simple'],undef,$ct_eid);
	$dbh->do(q[UPDATE exchange 
			  SET e_status='deleted' WHERE e_id=?
			],undef,$ct_eid);
		

	




	my($back_1,$back_2)=$dbh->selectrow_array(q[SELECT e_tid1,e_tid2
	 FROM exchange WHERE e_id=?],undef,$ct_eid);

	$dbh->do(q[
		UPDATE 	exchange SET 
		e_back_tid1=?,e_back_tid2=? 
		WHERE e_id=?
	],undef,$back_1,$back_2,$id);

	


 	return '<root> ok !</root>'



}

sub delete_transfer_by_transaction
{

	my $self=shift;
	my $id=$self->query->param('id');
	my $tid=$id;
	$id=$dbh->selectrow_array(q[SELECT  at_id FROM accounts_transfers WHERE at_tid=?],undef,$id);

    if(!$id){ 
	           my $drid=$dbh->selectrow_array(q[SELECT dp_id FROM documents_payments 
            	           WHERE dp_tid=?],undef,$tid);
               if($drid){
    
	    	               $self->query->param('id',$drid);
	                       return    $self->delete_document_payment();
			           
	           }

               $drid=$dbh->selectrow_array(q[SELECT dr_id FROM documents_requests  
                           WHERE dr_close_tid=?],undef,$tid);
                
                if($drid){
                    $self->query->param('param',$drid);
                    $self->ajax_reopen_doc();
                }

	            return  "<root>something wrong</root>"; 
    }
										      
	
	my $res=$dbh->do(q[UPDATE accounts_transfers SET at_status='deleted' 
		WHERE at_id=? AND at_status='processed'],undef,$id);

	if($res ne '1')
	{
			return  "<root>something wrong</root>";  
	}
	
	my $ref=$dbh->selectrow_hashref(q[SELECT t_id,t_aid2,t_aid1,t_currency,t_amnt,t_comment,at_tid,at_id FROM 
	transactions,accounts_transfers  WHERE at_tid=t_id AND at_id=?],undef,$id);
	
	my $tid = $self->add_trans(
	{
      		t_name1 =>$ref->{t_aid2},
    		t_name2 => $ref->{t_aid1},
      		t_currency => $ref->{t_currency},
      		t_amnt =>$ref->{t_amnt} ,
      		t_comment =>" Удаление трансфера ".$ref->{t_comment},
		
     
      	});
	$dbh->do(qq[
		INSERT $SQL_DELAYED INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
		select 
		t_id,
		`transactions`.`t_aid2` AS `t_aid2`,
		`transactions`.`t_comment` AS	`t_comment`,
		`operators`.`o_id` AS `o_id`,`operators`.`o_login` AS `o_login`,
		`transactions`.`t_aid1` AS 
		`t_aid1`,`accounts`.`a_name` AS `a_name`,`transactions`.`t_amnt` AS 
		`t_amnt`,`transactions`.`t_currency` 
		 AS `t_currency`,
		0 AS `0`,
		`transactions`.`t_amnt` AS `t_amnt`,
		0 AS `0`,
		0 AS `0`,
		cast(`transactions`.`t_ts` as date) AS `t_ts`,
		`transactions`.`t_currency` AS `t_currency`,
		0 AS `0`,
		0 AS `0`,'transaction' AS `transaction`,
		`transactions`.`t_ts` AS `ts`,
		'0000-00-00 00:00:00',
		'deleted',
		16777215  
		from ((`transactions` join `operators`) join `accounts`) 
		WHERE (1 and (`operators`.`o_id` = `transactions`.`t_oid`) 
		and (((`transactions`.`t_aid1` > 1) and (`transactions`.`t_aid2` > 1)) 
		) 
		and (`accounts`.`a_id` = `transactions`.`t_aid1`))
		AND t_id=? LIMIT 1
	
	],undef,$tid);

	$dbh->do(qq[
		INSERT $SQL_DELAYED INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
		select 
		t_id,
		`transactions`.`t_aid1` AS `t_aid1`,
		`transactions`.`t_comment` AS `t_comment`,
		`operators`.`o_id` AS `o_id`,
		`operators`.`o_login` AS `o_login`,
		`transactions`.`t_aid2` AS `t_aid2`,
		`accounts`.`a_name` AS `a_name`,
		-(`transactions`.`t_amnt`) AS `-t_amnt`,
		`transactions`.`t_currency` AS `t_currency`,
		0 AS `0`,
		-(`transactions`.`t_amnt`) AS `-t_amnt`,
		0 AS `0`,0 AS `0`,
		cast(`transactions`.`t_ts` as date) AS `t_ts`,
		`transactions`.`t_currency` AS `t_currency`,0 AS `0`,0 AS `0`,
		'transaction' AS `transaction`,
		`transactions`.`t_ts` AS `ts`,
		'0000-00-00 00:00:00',
		'deleted',
		16777215  
		from ((`transactions` join `operators`) join `accounts`) 
		where
		 (1 and (`operators`.`o_id` = `transactions`.`t_oid`) 
		and (((`transactions`.`t_aid1` > 1) 
		and (`transactions`.`t_aid2` > 1))) and (`accounts`.`a_id` = 
		`transactions`.`t_aid2`))
		AND t_id=? LIMIT 1
	
	],undef,$tid);

	$dbh->do(q[UPDATE 
		accounts_reports_table SET ct_status='deleted' 
		WHERE 
		ct_id=? AND ct_ex_comis_type='transaction'],undef,$ref->{t_id});

	$dbh->do(q[UPDATE 
		accounts_transfers 
		SET at_tid_back=?,at_status='deleted'
		WHERE at_id=?],undef,$tid,$id);
	$dbh->do(
		q[UPDATE 
		transactions 
		SET t_status='no' 
		WHERE t_id=? ],undef,$tid);

  	return  "<root>ok!</root>";

}


sub delete_transfer
{

	my $self=shift;
	my $id=$self->query->param('id');
	
	
	

	my $res=$dbh->do(q[UPDATE accounts_transfers SET at_status='deleted' 
		WHERE at_id=? AND at_status='processed'],undef,$id);

	if($res ne '1')
	{
			return  "<root>something wrong</root>";  
	}
	
	my $ref=$dbh->selectrow_hashref(q[SELECT t_id,t_aid2,t_aid1,t_currency,t_amnt,t_comment,at_tid,at_id FROM 
	transactions,accounts_transfers  WHERE at_tid=t_id AND at_id=?],undef,$id);
	
	my $tid = $self->add_trans(
	{
      		t_name1 =>$ref->{t_aid2},
    		t_name2 => $ref->{t_aid1},
      		t_currency => $ref->{t_currency},
      		t_amnt =>$ref->{t_amnt} ,
      		t_comment =>" Удаление ".$ref->{t_comment},
		
     
      	});
	$dbh->do(qq[
		INSERT $SQL_DELAYED INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
		select 
		t_id,
		`transactions`.`t_aid2` AS `t_aid2`,
		`transactions`.`t_comment` AS	`t_comment`,
		`operators`.`o_id` AS `o_id`,`operators`.`o_login` AS `o_login`,
		`transactions`.`t_aid1` AS 
		`t_aid1`,`accounts`.`a_name` AS `a_name`,`transactions`.`t_amnt` AS 
		`t_amnt`,`transactions`.`t_currency` 
		 AS `t_currency`,
		0 AS `0`,
		`transactions`.`t_amnt` AS `t_amnt`,
		0 AS `0`,
		0 AS `0`,
		cast(`transactions`.`t_ts` as date) AS `t_ts`,
		`transactions`.`t_currency` AS `t_currency`,
		0 AS `0`,
		0 AS `0`,'transaction' AS `transaction`,
		`transactions`.`t_ts` AS `ts`,
		'0000-00-00 00:00:00',
		'deleted',
		16777215  
		from ((`transactions` join `operators`) join `accounts`) 
		WHERE (1 and (`operators`.`o_id` = `transactions`.`t_oid`) 
		and (((`transactions`.`t_aid1` > 1) and (`transactions`.`t_aid2` > 1)) 
		) 
		and (`accounts`.`a_id` = `transactions`.`t_aid1`))
		AND t_id=? LIMIT 1
	
	],undef,$tid);

	$dbh->do(qq[
		INSERT $SQL_DELAYED INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
		select 
		t_id,
		`transactions`.`t_aid1` AS `t_aid1`,
		`transactions`.`t_comment` AS `t_comment`,
		`operators`.`o_id` AS `o_id`,
		`operators`.`o_login` AS `o_login`,
		`transactions`.`t_aid2` AS `t_aid2`,
		`accounts`.`a_name` AS `a_name`,
		-(`transactions`.`t_amnt`) AS `-t_amnt`,
		`transactions`.`t_currency` AS `t_currency`,
		0 AS `0`,
		-(`transactions`.`t_amnt`) AS `-t_amnt`,
		0 AS `0`,0 AS `0`,
		cast(`transactions`.`t_ts` as date) AS `t_ts`,
		`transactions`.`t_currency` AS `t_currency`,0 AS `0`,0 AS `0`,
		'transaction' AS `transaction`,
		`transactions`.`t_ts` AS `ts`,
		'0000-00-00 00:00:00',
		'deleted',
		16777215  
		from ((`transactions` join `operators`) join `accounts`) 
		where
		 (1 and (`operators`.`o_id` = `transactions`.`t_oid`) 
		and (((`transactions`.`t_aid1` > 1) 
		and (`transactions`.`t_aid2` > 1))) and (`accounts`.`a_id` = 
		`transactions`.`t_aid2`))
		AND t_id=? LIMIT 1
	
	],undef,$tid);

	$dbh->do(q[UPDATE 
		accounts_reports_table SET ct_status='deleted' 
		WHERE 
		ct_id=? AND ct_ex_comis_type='transaction'],undef,$ref->{t_id});

	$dbh->do(q[UPDATE 
		accounts_transfers 
		SET at_tid_back=?,at_status='deleted'
		WHERE at_id=?],undef,$tid,$id);
	$dbh->do(
		q[UPDATE 
		transactions 
		SET t_status='no' 
		WHERE t_id=? ],undef,$tid);

  	return  "<root>ok!</root>";

}

sub back_firm_req
{
	my $self=shift;
	my $id=$self->query->param('id');
	my $r_=$dbh->do(q[UPDATE  
	cashier_transactions SET ct_status='processing' 
	WHERE ct_id=? AND ct_status IN ('processed') ],undef,$id);
	
	if($r_ ne '1')
	{
	
		return '<root>error!missing such id !</root>';

	}
	
	my $ref=$dbh->selectrow_hashref(q[SELECT * 
 	FROM cashier_transactions WHERE ct_id=? AND ct_status='processing' ],undef,$id);
	my $str;
	my $firm=get_firm_name($ref->{ct_fid});
	my ($comis,$ext_comis);
	$comis={};
	$ext_comis={};
	my %obj;
	if($ref->{ct_tid2_ext_com})
	{
	
		$ext_comis=$dbh->selectrow_hashref(q[SELECT  t_aid1,t_aid2,t_amnt FROM  transactions WHERE 
		t_id=? ],undef,$ref->{ct_tid2_ext_com}); 
	}
	
	if($ref->{ct_tid2_comis})
	{
		$comis=$dbh->selectrow_hashref(q[SELECT  t_aid1,t_aid2,t_amnt 
						FROM  
						transactions 
						WHERE t_id=? ],undef,$ref->{ct_tid2_comis}); 
		
	}
			my $comis_sum=0;
			if($comis&&$comis->{t_amnt})
			{	
					$comis_sum+=$comis->{t_amnt};
					$obj{ct_tid2_comis}=$self->add_trans({
							t_name1 =>$comis_aid,
							t_name2 =>$comis->{t_aid1},
							t_currency => $ref->{ct_currency},
							t_amnt =>$comis->{t_amnt} ,
							t_comment => 
						"Откат  комиссии  $ref->{ct_id} при идентификации  
						'$ref->{ct_comment}'",
					});
				
			}
			if($ext_comis&&$ext_comis->{t_amnt})
			{
					$comis_sum+=$ext_comis->{t_amnt};

					$obj{ct_tid2_ext_com}=$self->add_trans({
								t_name1 =>$comis_aid,
								t_name2 =>$ext_comis->{t_aid1} ,
								t_currency => $ref->{ct_currency},
								t_amnt =>$ext_comis->{t_amnt} ,
								t_comment => 
							"Откат дополнительной комиссии $ref->{ct_id} при идентификации  
							'$ref->{ct_comment}'",
						});
			
			}
		
			my $sum=0;
			
			##for plus or mines
			if($ref->{ct_amnt}>0)
			{
				
				$obj{ct_tid2}=$self->add_trans({
					t_name1 =>$ref->{ct_aid},
					t_name2 =>$firms_id,
					t_currency =>$ref->{ct_currency},
					t_amnt =>abs($ref->{ct_amnt}),
					t_comment => "Откат  идентификации  $ref->{ct_id} '$ref->{ct_comment}'",
					});
				$sum=-1*$ref->{ct_amnt};		
			
			}else
			{
				$obj{ct_tid2}=$self->add_trans({
						t_name1 =>$firms_id,
						t_name2 =>$ref->{ct_aid},
						t_currency =>$ref->{ct_currency},
						t_amnt =>abs($ref->{ct_amnt}),
						t_comment => "Откат  идентификации  $ref->{ct_id} 
						'$ref->{ct_comment}'",
					});
				$sum=abs($ref->{ct_amnt});

			}
		
			if($ref->{ct_eid})
			{
				
	
				my $r=$dbh->selectrow_hashref(q[SELECT * FROM exchange_view WHERE 
				e_id=?],undef,$ref->{ct_eid});
				
				$r->{e_rate}=pow($r->{e_rate},-1) if($r->{e_currency2} eq $r->{e_currency1});
				 
				$obj{ct_eid}=$self->add_exc(
				{
				type=>'auto',
				rate=>pow($r->{e_rate},$RATE_FORMS{$r->{e_currency1}}->{$r->{e_currency2}}),
				e_comment=>qq[Откат автообмена при  идентификации #$ref->{ct_id}],
				e_currency1=>$r->{e_currency2},
				e_currency2=>$r->{e_currency1},
				e_amnt1=>$r->{e_amnt2},
				a_id=>$ref->{ct_aid},
				}
				);
				
				
				
			
				
			}


	
	$dbh->do(qq[INSERT  INTO cashier_transactions SET
	ct_comment=?,
	ct_amnt=?,
	ct_currency=?,
	ct_status='deleted',
	ct_ts=current_timestamp,
	ct_ts2=current_timestamp,
	ct_date=current_timestamp,
	ct_aid=?,
	ct_oid2=?,
	ct_fid=?,
	ct_ext_commission=?,
	ct_comis_percent=?,
	ct_eid=?,
	ct_tid2=?,
	ct_tid2_ext_com=?,
	ct_tid2_comis=?,
	ct_oid=?
	],undef,qq[Откат идентификации #$ref->{ct_id} '$ref->{ct_comment}' ],
	$sum,$ref->{ct_currency},$ref->{ct_aid},
	$self->{user_id},
	$ref->{ct_fid},
	-1*$ref->{ct_ext_commission},
	-1*$ref->{ct_comis_percent},
	$obj{ct_eid},
	$obj{ct_tid2},
	$obj{ct_tid2_ext_com},
	$obj{ct_tid2_comis},
	$self->{user_id}
	);
	my $rev_id=$dbh->selectrow_array(q[SELECT last_insert_id()]);
	$dbh->do(q[
	UPDATE cashier_transactions SET 
	ct_status='deleted'
	 WHERE
	ct_id=?
	],undef,$id);
	$dbh->do(q[UPDATE accounts_reports_table SET ct_status='deleted' 
	WHERE ct_id=? AND ct_ex_comis_type IN ('input','in_rate') ],undef,$id);

	if($sum<0)
	{
		$dbh->do(qq[INSERT $SQL_DELAYED INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
		select `cashier_transactions`.`ct_id` AS `ct_id`,`cashier_transactions`.`ct_aid` AS `ct_aid`,
		`cashier_transactions`.`ct_comment` AS `ct_comment`,
		`cashier_transactions`.`ct_oid` AS `ct_oid`,
		`operators`.`o_login` AS `o_login`,
		`firms`.`f_id` AS `ct_fid`,
		`firms`.`f_name` AS `f_name`,
		`cashier_transactions`.`ct_amnt` AS `ct_amnt`,
		`cashier_transactions`.`ct_currency` AS `ct_currency`,
		if((`cashier_transactions`.`ct_eid` is not null),
		if((`cashier_transactions`.`ct_ex_comis_type` = _cp1251'in_rate'),
		((1 / `exchange_view`.`e_rate`) * ((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_amnt`) - 
		(`cashier_transactions`.`ct_amnt` * (`exchange_view`.`e_rate` + 
		((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
		((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100)),
		((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100)) AS `comission`,
		if((`cashier_transactions`.`ct_eid` is not null),
		`exchange_view`.`e_amnt1`,(`cashier_transactions`.`ct_amnt` - 
		((`cashier_transactions`.`ct_comis_percent` * abs(`cashier_transactions`.`ct_amnt`)) / 100))) AS `result_amnt`,
		`cashier_transactions`.`ct_comis_percent` AS `ct_comis_percent`,
		(-(1) * `cashier_transactions`.`ct_ext_commission`) AS `ct_ext_commission`,
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
		(((`cashier_transactions` left join `exchange_view` on((`exchange_view`.`e_id` = `cashier_transactions`.`ct_eid`))) 
		left join `firms` on((`cashier_transactions`.`ct_fid` = `firms`.`f_id`))) 
		left join `operators` on((`cashier_transactions`.`ct_oid` = `operators`.`o_id`))) 
		where ((`cashier_transactions`.`ct_amnt` < 0) 
		AND (`cashier_transactions`.`ct_status` in (_cp1251'deleted'))) 
		AND ct_id=? LIMIT 1],undef,$rev_id);	

		
	
	
	}else
	{
			$dbh->do(qq[INSERT $SQL_DELAYED INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,col_status,ct_status,col_color)
		SELECT `cashier_transactions`.`ct_id` AS `ct_id`,`cashier_transactions`.`ct_aid` 
		AS `ct_aid`,
		`cashier_transactions`.`ct_comment` AS `ct_comment`,
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
		`cashier_transactions`.`col_status` AS `col_status`,
		`cashier_transactions`.`col_ts` AS `col_ts`,
		`cashier_transactions`.`ct_status` AS `ct_status`,
		`cashier_transactions`.`col_color` AS `col_color` 
		from (((`cashier_transactions` 
		left join `exchange_view` on((`exchange_view`.`e_id` = `cashier_transactions`.`ct_eid`))) 
		left join `firms` on((`cashier_transactions`.`ct_fid` = `firms`.`f_id`))) 
		left join `operators` on((`cashier_transactions`.`ct_oid` = `operators`.`o_id`)))
		where (1  AND ct_id=? AND (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` 
		in (_cp1251'deleted'))) LIMIT 1 ],undef,$rev_id);


	
	}


	
	
	my $ct_req='no';
	if($ref->{ct_currency} ne $RESIDENT_CURRENCY)
	{
		$ct_req='yes';
		my $cur=lc($ref->{ct_currency});
		$dbh->do(qq[UPDATE firms SET f_$cur=f_$cur+? WHERE f_id=?],undef,-1*$ref->{ct_amnt},$ref->{ct_fid});
		$ref->{ct_date}=$dbh->selectrow_array('SELECT current_date');

	}
	
	
	$dbh->do(qq[
		INSERT  INTO 
		cashier_transactions 
		SET
	 	ct_status='created',ct_req=?,ct_oid=?,ct_comment=?,
		ct_ts=current_timestamp,ct_date=?,
		ct_fid=?,ct_amnt=?,ct_currency=?
	 	],
	undef,
	$ct_req,
	$self->{user_id},
	$ref->{ct_comment},
	$ref->{ct_date},
	$ref->{ct_fid},
	$ref->{ct_amnt},
	$ref->{ct_currency}
	);
	my $last_insert_id=$dbh->selectrow_array('SELECT last_insert_id()');

	$dbh->do(q[DELETE FROM non_resident_payments WHERE nrp_ctid=?],undef,$id);
	


	return qq[$last_insert_id];

   
  

}
sub delete_firm_req
{
	 my $self = shift;
        my $id=$self->query->param('id');
   
  	 my ($amnt,$currency,$fid,$percent,$req)=$dbh->selectrow_array(q[SELECT 
	ct_amnt,ct_currency,ct_fid,f_percent,ct_req from cashier_transactions,
	firms  where ct_status='created' AND ct_fid=f_id  AND  ct_fid>0  AND ct_id=?],undef,$id);

  	 my $res=$dbh->do(q[UPDATE cashier_transactions 
	SET ct_status='deleted',ct_ts2=ct_ts,ct_oid2=? WHERE ct_status='created' 
   	AND ct_fid>0  AND ct_id=?],undef,$self->{user_id},$id);	   

   if($res ne '1')
   {
	return '<root>error!missing such id !</root>';
     
	 
   }
#    open(FL,"$FILE_PATH_LOG") or die $!;
#    print FL "delete $amnt of $currency FROM $fid \n";
#    close(FL);
   
   $currency=lc($currency);
  if($req eq 'no')
  {
	
		$dbh->do(qq[UPDATE firms SET f_$currency=f_$currency+? WHERE f_id=?],undef,-1*$amnt,$fid);
			
	
  }

	

  $dbh->do(q[DELETE FROM  non_resident_payments  WHERE nrp_ctid=? ],undef,$id);
	
  $dbh->do(qq[INSERT  INTO cashier_transactions 
			SET ct_status='deleted',
			ct_amnt=?,ct_currency=?,ct_fid=?,
			ct_date=NOW(),ct_ts2=NOW(),ct_oid2=?,ct_ts=current_timestamp  
	 	  ],undef,-1*$amnt,$currency,$fid,$self->{user_id}) if($req eq 'no');
	
	    #my $my_id=$dbh->selectrow_array(q[SELECT last_insert_id()]);
	   
	return '<root> ok !</root>'
}

sub set_col_all
{
	my  $self=shift;
	my $a_id=$self->query->param('a_id');

	my $status=$self->query->param('col_status');
	my %statuses=('yes'=>'yes','no'=>'no');

	$status='yes' unless($statuses{$status});
=pod
	$dbh->do(q[ UPDATE cashier_transactions SET col_status=?,col_color=16777215 WHERE ct_aid=? ],undef,$statuses{$status},$a_id);
	$dbh->do(q[ UPDATE transactions SET col_status=?,col_color=16777215 WHERE (t_aid1=? OR t_aid2=?) ],undef,$statuses{$status},$a_id,$a_id);
	$dbh->do(q[ UPDATE exchange SET col_status=?,col_color=16777215 WHERE  e_tid1 IN 
	(SELECT t_id FROM transactions WHERE t_aid1=?)	],undef,$statuses{$status},$a_id);
=cut
	
	$dbh->do(qq[UPDATE accounts_reports_table SET col_color=16777215,col_status=?,
		col_ts=current_timestamp WHERE 
		1 AND ct_aid=? 
		],undef,$statuses{$status},$a_id);

	return '<root> ok !</root>'
}

sub set_col_no
{
	my $self=shift;
	my %params=map {$_=>$self->query->param($_) } $self->query->param();


	my %tables=(
			input=>'cashier_transactions',
			in_rate=>'cashier_transactions',
		        simple=>'exchange',
		        transaction=>'transactions',
	
	);
	my %com=(
			input=>'ct_comment',
			in_rate=>'ct_comment',
		        simple=>'t_comment',
		        transaction=>'t_comment',
	
	);

	my %ids=(
			input=>'ct_id',
			in_rate=>'ct_id',
		        simple=>'e_id',
		        transaction=>'t_id',
	
	);

	my $color=16777215;	
		

=pod
	this doesn't need and ambigous now	

	$dbh->do(qq[UPDATE $type SET col_status=?,
	col_ts=current_timestamp,col_color=$color WHERE 1 AND
	$id=?],	undef,'no',$params{'id'}) || die $type;
=cut

	my $type=$tables{$params{'type'}};
	my $id=$ids{$params{'type'}};
	
	$tables{simple}='exchange_view';


	my $com=$com{$params{'type'}};
	$type=$tables{$params{'type'}};

	my $old_comment=$dbh->selectrow_array(qq[SELECT $com FROM $type WHERE $id=? ],undef,$params{'id'});
	
	$dbh->do(qq[UPDATE accounts_reports_table SET col_status=?,
	col_ts=current_timestamp,col_color=$color,ct_comment=? WHERE 
	1 AND ct_id=? AND ct_ex_comis_type=? AND ct_aid=?],undef,'no',$old_comment,$params{'id'},$params{'type'},$params{ct_aid});
	return $old_comment;
}
sub set_col
{
	my  $self=shift;
	my %params=map {$_=>$self->query->param($_) } $self->query->param();
	my %statuses=('yes'=>'yes','no'=>'no');
	my %tables=(
			input=>'cashier_transactions',
			in_rate=>'cashier_transactions',
		        simple=>'exchange',
		        transaction=>'transactions',
	
	);
	my %ids=(
			input=>'ct_id',
			in_rate=>'ct_id',
		        simple=>'e_id',
		        transaction=>'t_id',
	
	);
	


	my $color=$dbh->selectrow_array(q[SELECT 
	min(col_color) FROM accounts_reports_table WHERE ct_aid=?],undef,$params{ct_aid});
	$color=16777215 unless($color);

	



	$color-=30;
	$color=16777185	if($color<0);	
	my ($i,$type,$id);
	$id=0;
	$type='';
	require Encode;
	Encode::from_to($params{comment},'utf8','cp1251');
	
	for($i=0;$i<$params{size};$i++)
	{
		$type=$tables{$params{'type'.$i}};
		
		$id=$ids{$params{'type'.$i}};
=pod
		$dbh->do(qq[ UPDATE $type SET col_status=?,
		col_ts=current_timestamp,col_color=? WHERE 1 AND
		$id=?],
		undef,$params{col_status},$color,$params{'id'.$i}) || die $type if($type ne 'transaction');
=cut
	
			#die $params{comment};
		if($params{comment})
		{	
			$dbh->do(qq[ UPDATE accounts_reports_table 
			SET col_status=?,
			col_ts=current_timestamp,
			col_color=$color,
			ct_comment=? 
			WHERE 
			1 AND ct_id=? 
			AND 
			ct_ex_comis_type=? 
			AND ct_aid=?],undef,
			$params{col_status},$params{comment},$params{'id'.$i},$params{'type'.$i},$params{ct_aid});
		}else
		{
			$dbh->do(qq[ UPDATE accounts_reports_table 
			SET col_status=?,
			col_ts=current_timestamp,
			col_color=$color
			WHERE 
			1 AND ct_id=? 
			AND 
			ct_ex_comis_type=? 
			AND ct_aid=?],
			undef,$params{col_status},$params{'id'.$i},$params{'type'.$i},$params{ct_aid});
			
	
		}

	}	
	return "$params{comment}";


}
sub search_amnt
{
	my $self=shift;
	my %params;
	map { $params{$_}=$self->query->param($_) } $self->query->param();

   
   	if($params{ct_amnt})
   	{
		my $txt="<root>";
		
		
		my $search=$dbh->selectrow_array(q[SELECT a_name 
		FROM accounts WHERE a_id=?],undef,$params{search_account});
		$search=substr($search,0,3);
		
		my $ref=$dbh->selectall_arrayref(qq[
		SELECT 
		DATE_FORMAT(ct_date,'%d.%c.%Y'),
		ct_amnt,
		ct_currency,
		ct_comment,
		ct_status,
		a_name 
		FROM 
		cashier_transactions,accounts 
		WHERE 	
		ct_aid=a_id
		AND	
		ct_fid=-1
		AND
		(a_name like '$search%'	OR a_name=$params{search_account})
		AND
		abs(ct_amnt)=abs(?)
		AND ( date_sub(current_timestamp,interval 14 day)<ct_ts2 
		OR  (date_sub(current_timestamp,interval 14 day)<ct_ts) 
		)
	  	
 		],
		undef,$params{ct_amnt}
		);
	
		my %statuses=(
			canceled=>'Отменен',
			created=>'Создан',
			returned=>'Возвращен',
			processed=>'Проведен',

		);

		foreach(@$ref)
		{
			$_->[0]=~s/[&]/&amp;/g;
			$_->[0]=~s/[<]/&lt;/g;
			$_->[0]=~s/[>]/&gt;/g;
			$_->[0]=~s/[']/&apos;/g;
			$_->[0]=~s/["]/&quot;/g;

			$_->[5]=~s/[&]/&amp;/g;
			$_->[5]=~s/[<]/&lt;/g;
			$_->[5]=~s/[>]/&gt;/g;
			$_->[5]=~s/[']/&apos;/g;
			$_->[5]=~s/["]/&quot;/g;
			$_->[4]=$statuses{$_->[4]};
			$txt.='<record>';
			$txt.="$_->[0]: $_->[4] ";
			$txt.="$_->[1] ";
			$txt.=$conv_currency->{$_->[2]};
			$txt.=", назначение :  $_->[3]  ";
			$txt.="<user>$_->[5]</user>";		
			$txt.='</record>';
		}
		return $txt.'</root>';
	}	
   	return  "<root></root>"; 		
}



sub get_account_services_percent
{
   my $self = shift;
   my $service_id=$self->query->param('service');
   if($service_id)
   {
	my $txt="<root>";
	my $ref=$dbh->selectall_arrayref(q[SELECT
	  cs_aid,cs_fsid,cs_percent FROM client_services,firm_services WHERE cs_fsid=? 
	  AND cs_fsid=fs_id  AND fs_status='active' ],
	undef,$service_id);
	foreach(@$ref)
	{
		$txt.='<accounts><user>'.$_->[0].'</user>';
		$txt.='<service>'.$_->[1].'</service>';
		$txt.='<percent>'.$_->[2].'</percent>';
		$txt.="</accounts>\n";
	}
	return $txt.'</root>';

   }	
   return  "<root></root>"; 	
   	
  
  
}
sub get_firm_services
{
   my $self = shift;
   my $firm=$self->query->param('firm');
   my $services;
   ($firm,$services)=$dbh->selectrow_array(q[SELECT f_id,f_services FROM firms  WHERE  f_id=?],undef,$firm);
   $services=trim($services);
	   
   if($firm&&$services)
   {
	
	my $ref=set2hash($services);
	my $obj=join(',',keys %$ref);
	my $txt="<root>";
	$ref=$dbh->selectall_arrayref(qq[SELECT fs_id,fs_name FROM firm_services 
	WHERE fs_id IN ($obj) AND fs_status='active' ]);

	foreach(@$ref)
	{
		$txt.='<service><fs_id>'.$_->[0].'</fs_id>';
		$txt.='<fs_name>'.$_->[1].'</fs_name>';
		$txt.="</service>\n";
	}
	return $txt.'</root>';
	
  
   }else
   {		
   		return  "<root></root>"; 	
   }  	
  
  
}
sub get_right
{
	return 'index';
}

1;
