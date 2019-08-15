package Documents;
use strict;
use base qw[Exporter];
use SiteDB;
use Rights;
use SiteCommon;
our @EXPORT = qw(
	set_calc_persent_comissions
	get_calc_persent_comissions
	get_out_firms
	add_document
	get_payment_
    get_out_firms_okpo
    update_documents_requests_trans
    reclose_doc
);
sub get_out_firms_okpo
{
        my $sql = qq[
         SELECT * FROM out_firms WHERE of_okpo IS NOT NULL
         ORDER BY binary lcase(of_name)
       ];
   
       my @titles=();
       my $sth =$dbh->prepare($sql);
       $sth->execute();                          
       while(my $r = $sth->fetchrow_hashref)
       {
            push @titles, {"value"=>$r->{of_id}, "title"=>"$r->{of_okpo}"};
       }

       $sth->finish();
       return \@titles;


}
sub reclose_doc
{
    my ($self,$dr_id)=@_;
    my $ref=$dbh->selectrow_hashref(q[SELECT * FROM documents_requests
    WHERE dr_id=? 
            ],undef,$dr_id);

    my $del_id=$self->del_trans($ref->{dr_close_tid});

    $dbh->do(qq[UPDATE accounts_reports_table SET ct_status='deleted' 
        WHERE ct_ex_comis_type='transaction' 
                AND  ct_id IN (?,?) ],undef,$del_id,$ref->{dr_close_tid});
      my $ref1=get_transaction_info($ref->{dr_close_tid});
    
      my $new_id=$self->add_trans(
                    {
                        t_name1 => $DOCUMENTS,
                        t_name2 =>  $ref->{dr_aid},
                        t_currency => $ref->{dr_currency},
                        t_amnt => $ref->{dr_comis}*($ref->{dr_amnt}/100),
                        t_comment => $ref1->{t_comment}, 
                        t_status=>'system',
                     });

       $dbh->do(q[UPDATE documents_requests SET dr_close_tid=? WHERE dr_id=?],undef,$new_id,$dr_id);
       return $new_id;

}

sub get_out_firms
{
	
	   my $sql = qq[
      	 SELECT * FROM out_firms
      	 ORDER BY binary lcase(of_name)
       ];
   
       my @titles=();
       my $sth =$dbh->prepare($sql);
       $sth->execute();                          
       while(my $r = $sth->fetchrow_hashref)
       {
	        push @titles, {"value"=>$r->{of_id}, "title"=>"$r->{of_name} (id#$r->{of_id})"};
       }
       unshift @titles,{"value"=>'', "title"=>"Новая"};

       $sth->finish();
       return \@titles;
	
	
}
sub set_calc_persent_comissions
{
	my $params=shift;
	my $temp_params=$params->{hash}->{dr_id};
	

	my $ref=$dbh->selectall_hashref(qq[SELECT 
					  CONCAT(dr_fid,'_',dr_aid,'_',dr_currency,'_',dr_ofid_from) as key_field ,
					  sum(t_amnt) as payed_comis,dr_id
					  FROM
					      documents_requests,
					      cashier_transactions,
					      transactions, 
					      documents_payments 
					      WHERE dp_ctid=ct_id AND dr_aid!=0  AND dp_tid=t_id
					      AND dp_drid=dr_id AND (ct_status='processed' OR ct_id=0)   
					      $params->{filter_where}  AND  $params->{proto}->{extra_where} 
					      GROUP BY dr_fid,dr_aid,dr_currency,dr_ofid_from,dr_date ],'dr_id');
	
	
	my %comises;
	

#	use Data::Dumper;
#	die Dumper $temp_params;
	
	
	foreach(keys %{$ref})
	{
	
	
	    	$temp_params->{$_}->{compare_payed_comis}=$ref->{$_}->{payed_comis};
		$temp_params->{$_}->{payed_comis}=format_float($ref->{$_}->{payed_comis});
				
		next 		unless($temp_params->{$_}->{compare_sum_comis});
		$temp_params->{$_}->{payed_income}=format_float(to_prec6($temp_params->{$_}->{compare_dr_amnt}*($temp_params->{$_}->{compare_payed_comis}/$temp_params->{$_}->{compare_sum_comis})));
	}
	

}

sub get_payment_
{
    	my $self=shift;
	    my $ref=shift;
	
	   return  1 unless(@$ref);
	   my $sum=0;
	   my @ct_id;
	   my $str=join(',',@$ref);

	   my $dr_ids=$dbh->selectall_hashref(qq[SELECT 
	                        dr_id,
                            dr_id as id,
	                        sum(t_amnt) as payed,
	                        dr_comis*(dr_amnt/100) as sum_comis,
	                        dr_currency,
	                        dr_comis*(dr_amnt/100)-sum(t_amnt) as last_sum,
	                        a_usd,
                            a_uah,
	                        a_eur,
                            a_id,
	                        f_name,
	                        dr_amnt,
	                        dr_comis,
	                        of_name,
	                        dr_date,
                            dr_status
  	    FROM
		    documents_requests,
	        transactions,
  		    documents_payments,
  	        accounts,
		    firms,out_firms
	        WHERE dp_tid=t_id     
			AND dr_fid=f_id
			AND dr_ofid_from=of_id
			AND dr_id=dp_drid 
		   	AND dr_status IN ('created','processed')
        	AND dr_aid=a_id  AND dr_id IN ($str) 
			GROUP BY dr_id],'dr_id');
        
			
			my $sql=q[INSERT INTO documents_payments(dp_drid,dp_ctid,dp_tid,dp_amnt) VALUES];
  		    my $purses={USD=>'a_usd',UAH=>'a_uah',EUR=>'a_eur'};
			my $sum=0;
            my $i=0;
				foreach my $key (keys %$dr_ids){
                    
			        next	if($dr_ids->{$key}->{last_sum}<=0);
				    $dr_ids->{$key}->{dr_comis}=to_prec($dr_ids->{$key}->{dr_comis});
				     $i++;   
		    
    
                    $sum=$dr_ids->{$key}->{last_sum};
                    format_datetime_month_year(\$dr_ids->{$key}->{dr_date});
				    my $tid=$self->add_trans(
						    {  
						        t_status=>'system',
						        t_amnt=>$dr_ids->{$key}->{last_sum},
						        t_currency=>$dr_ids->{$key}->{dr_currency},
						        t_name1 => $dr_ids->{$key}->{a_id} ,
						        t_name2 => $DOCUMENTS,
						        t_comment => "Плата $dr_ids->{$key}->{dr_comis} % $dr_ids->{$key}->{dr_date}  за приход $dr_ids->{$key}->{dr_amnt} $dr_ids->{$key}->{f_name}  с $dr_ids->{$key}->{of_name} #$key ",
						    });
                     
                       $dr_ids->{$key}->{payed_comis}=$dr_ids->{$key}->{sum_comis};
                       update_documents_requests_trans($dr_ids->{$key});
                       reclose_doc($self,$key) if($dr_ids->{$key}->{dr_status} eq 'processed');
            
				        $sql.=qq[($key,0,$tid,$sum),];
				}
	        chop($sql);
            $dbh->do($sql)   if($i&&keys %$dr_ids);
		   
		    return 0	
}
sub addclose_doc
{
    my ($self,$ref)=@_;

    my $tid = $self->add_trans(
            {
                t_name1 =>$DOCUMENTS,
                t_name2 => $ref->{dr_aid},
                t_currency => $ref->{dr_currency},
                t_amnt =>$ref->{sum_comis},
                t_comment =>" закрытие сделки "."Плата $ref->{dr_comis} % $ref->{dr_date}  за приход $ref->{dr_amnt} $ref->{f_name}  с $ref->{of_name} #$ref->{dr_id} ",
                t_status =>'system'
         });

         $dbh->do(q[UPDATE documents_requests 
                    SET dr_close_tid=? WHERE dr_id=?],undef,$tid,$ref->{dr_id});

}
sub update_documents_requests_trans
{
	            my $q=shift;
	                
                    my $dt=$dbh->selectall_arrayref(q[SELECT dt_amnt,dt_id 
                                                FROM 
                                                documents_transactions 
                                                WHERE 
                                                dt_drid=?  
                                                AND dt_status IN ('processed')],undef,$q->{id});
            
                    my $dt_c=$dbh->selectall_arrayref(q[SELECT dt_amnt,dt_id 
                                                    FROM documents_transactions 
                                                    WHERE 
                                                    dt_drid=?  
                                                    AND dt_status IN ('created')],undef,$q->{id});
              
                    my $payed_sum=($q->{payed_comis}*100)/$q->{dr_comis}; 

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
                	    return;       
		    

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




}

sub add_document
{
		my $q=shift;

		my %q=%{$q};
    
        
		my $doc_id=$q{doc_id};
		my $params=$dbh->selectrow_hashref(q[SELECT * FROM documents_requests 
		WHERE  dr_currency=? AND dr_aid=? AND dr_ofid_from=? AND dr_fid=? 
		AND dr_status='created' AND dr_date=?],undef,
		$q{'dr_currency'},
		$q{'dr_aid'},
		$q{'dr_ofid_from'},
		$q{'dr_fid'},
		$q{'dr_date'},
		);

		$dbh->do(q[UPDATE documents_transactions  SET dt_drid=? WHERE dt_aid=? AND dt_currency=? AND dt_ofid=? AND dt_fid=? 
		AND dt_status='created' AND dt_date=? AND  dt_drid IS NULL],
		undef,$doc_id,
		$q{'dr_aid'},
		$q{'dr_currency'},
		$q{'dr_ofid_from'},
		$q{'dr_fid'},
        $q{'dr_date'},
		);



		if($params->{dr_id})
		{
			my $sum=$params->{dr_amnt}+$q{dr_amnt};
			$params->{dr_comis}= (($params->{dr_amnt}/$sum)*$params->{dr_comis})+(($q{dr_amnt}/$sum)*$q{dr_comis});
			$params->{dr_amnt}=$sum;
			$dbh->do(q[UPDATE documents_requests SET dr_comis=?,dr_amnt=? 
			WHERE dr_id=?],undef,$params->{dr_comis},$params->{dr_amnt},$params->{dr_id});

		}else
		{

			$dbh->do(q[INSERT INTO documents_requests(dr_id,
			dr_comis,
			dr_aid,
			dr_amnt,
			dr_comment,
			dr_fid,
			dr_status,dr_ts,dr_currency,dr_ofid_from,dr_oid,dr_date) 
			SELECT documents_requests_logs.dr_id,
			documents_requests_logs.dr_comis,documents_requests_logs.dr_aid,
			documents_requests_logs.dr_amnt,
			documents_requests_logs.dr_comment,
			documents_requests_logs.dr_fid,
			documents_requests_logs.dr_status,
			documents_requests_logs.dr_ts,
			documents_requests_logs.dr_currency,
			documents_requests_logs.dr_ofid_from,
			documents_requests_logs.dr_oid,
			dr_date
			FROM  
			documents_requests_logs WHERE documents_requests_logs.dr_id=?],undef,$doc_id);
			
			my $l_id=0;

			
			$dbh->do(qq[INSERT INTO documents_payments(dp_ctid,dp_drid,dp_tid) VALUES(?,?,?)],undef,$l_id,$doc_id,0);
		
			if($q{pay})
			{
				$dbh->do(qq[INSERT INTO cashier_transactions(ct_ts,ct_aid,ct_amnt,
				ct_currency,ct_comment,ct_oid,ct_status,ct_date)
				 VALUES(current_timestamp,?,?,?,?,?,'created',current_timestamp)
				],undef,$DOCUMENTS,
				$q{dr_comis}*($q{dr_amnt}/100),$q{dr_currency},$q{dr_comment},$q{user_id});
				

				my $l_id=$dbh->selectrow_array(q[SELECT last_insert_id()]);

				$dbh->do(qq[INSERT INTO documents_payments(dp_ctid,dp_drid,dp_tid) VALUES(?,?,?)],undef,$l_id,$doc_id,0);
		
				
			}


		
		}

}



sub get_calc_persent_comissions
{
	my $params=shift;



}
1;