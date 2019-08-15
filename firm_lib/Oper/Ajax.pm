package Oper::Ajax;
use strict;
use base 'CGIBaseOut';
use SiteConfig;
use SiteDB;
use SiteCommon;
#use lib $PMS_PATH;
use POSIX;
#this  package is needing  for  checking of all params

sub setup
{
  my $self = shift;
    
  $self->run_modes(
   'AUTOLOAD'=>'list',
    'ajax_del_doc_trans'   => 'ajax_del_doc_trans',
    'get_docs_for_firm'=>'get_docs_for_firm',
    'get_docs_for_firm_all'=>'get_docs_for_firm_all',
    'update_ctid_drid'=>'update_ctid_drid',
    'update_ctid_drid_many'=>'update_ctid_drid_many',
    'get_doc_firms_4many'=>'get_doc_firms_4many',
    'add_firm'=>'add_firm'
     );

}
sub update_ctid_drid_many{

    my $self=shift;
    my $rowid=$self->query->param('rowid'); 

##only this two lines changed for procedure 'update_ctid_drid'
    
    my $dr_id=$self->query->param('dr_id');
    my @ctids=split(/,/,$rowid);
    
    
    
    my $fids=get_operators_firms_hash($self->{user_id});
    my $fids_str=join ',',keys %$fids;
    
    
    foreach my $k(@ctids){
        $k=int($k);
    }
    my $str_ctid=join(',',@ctids);

   
    my $res=$dbh->do(qq[UPDATE cashier_transactions SET ct_from_drid=?  
               WHERE ct_id IN ($str_ctid) 
               AND ct_status 
               IN ('created','processed')
               AND  ct_fid IN ($fids_str) ],undef,$dr_id);
    return 'ok';
    



}
sub update_ctid_drid{

    my $self=shift;
    my $ct_id=$self->query->param('ct_id');
    my $dr_id=$self->query->param('dr_id');
    my $fids=get_operators_firms_hash($self->{user_id});
    my $fids_str=join ',',keys %$fids;
 
    my $res=$dbh->do(qq[UPDATE cashier_transactions SET ct_from_drid=?  
                        WHERE ct_id=? AND 
                        ct_status in ('created','processed') 
                        AND ct_fid IN ($fids_str)
               ],undef,$dr_id,$ct_id);
    

    if($res ne '1'){
        die "something wrong \n";
    
    }else{
        return 'ok';
    }

}
sub get_docs_for_firm_all{
    my $self=shift;
    my $f_id=$self->query->param('f_id');
    my $month=int($self->query->param('month'));
    
    my $year=int($self->query->param('year'));
    my $rowid=int($self->query->param('rowid'));
 
    my @res=();    
    
    

    my  $ref=$dbh->selectall_arrayref(qq[SELECT dr_id,dr_amnt,dr_date,
                                                concat(of_name,'( ',of_okpo,' )') as of,
                                                a_name
                                                FROM documents_requests,out_firms,accounts
                                                WHERE 1
                                                AND dr_aid=a_id
                                                and dr_status IN ('created','processed')
                                                AND    dr_ofid_from=of_id
                                                AND dr_fid=? 
                                                AND YEAR(dr_date)=? AND MONTH(dr_date)=?],
                                                undef,$f_id,$year,$month);
 
    
    foreach(@$ref){
        
         format_datetime_month_year(\$_->[2]);
         push @res,{
                    dr_id=>$_->[0],
                    dr_amnt=>$_->[1],
                    dr_date=>$_->[2],
                    of=>$_->[3],
                    a_name=>$_->[4],
#                     info=>$_->[2]." ".$_->[1]." ".$_->[3]." ".$_->[4]
                    };
    }

    $self->{tpl_vars}->{list}=\@res;
    my $file='';
    if ($rowid){
       $file='docs4money_list2.html'; 

    }else{
         $file='docs4money_list.html';
    }
    my $tmpl=$self->load_tmpl($file);
    my $output='';
    $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
    return $output;
    

}

sub get_doc_firms_4many{
    my $self=shift;
#    'data' : 'do=get_doc_firms_4many&f_id='+ct_fid+'&month='+month+'&year='+year+'&rowid='+rowid,
###repeat the procedure get_docs_for_firm_all but it is only for first time
    my $rowid=$self->query->param('rowid'); 
    my $ct_fid=$self->query->param('f_id'); 
    my $month=$self->query->param('month');
    my $year=$self->query->param('year');
    my @ctids=split(/,/,$rowid);
    

    my  $ref=$dbh->selectall_arrayref(qq[SELECT dr_id,dr_amnt,dr_date,
                                                concat(of_name,'( ',of_okpo,' )') as of,
                                                a_name
                                                FROM documents_requests,out_firms,accounts
                                                WHERE 1
                                                AND dr_aid=a_id
                                                and dr_status IN ('created','processed')
                                                AND    dr_ofid_from=of_id
                                                AND dr_fid=? 
                                                AND YEAR(dr_date)=? AND MONTH(dr_date)=?],
                                                undef,$ct_fid,$year,$month);
 
    my @res;
    foreach(@$ref){
        
         format_datetime_month_year(\$_->[2]);
         push @res,{
                    dr_id=>$_->[0],
                    dr_amnt=>$_->[1],
                    dr_date=>$_->[2],
                    of=>$_->[3],
                    a_name=>$_->[4],
#                     info=>$_->[2]." ".$_->[1]." ".$_->[3]." ".$_->[4]
                    };
    }

    $self->{tpl_vars}->{list}=\@res;
    my $file='';
    $file='docs4money_list3.html'; 
    my $tmpl=$self->load_tmpl($file);
    my $output='';
    $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
    return $output;
    

    
    
        

}

sub get_docs_for_firm{

    my $self=shift;
    my $of_id=$self->query->param('of_id');
    my $f_id=$self->query->param('f_id');
    my $month=int($self->query->param('month'));
    my $year=int($self->query->param('year'));
    my $rowid=int($self->query->param('rowid'));


    my ($of_name,$of_okpo)=$dbh->selectrow_array(q[SELECT of_name,of_okpo FROM out_firms WHERE of_id=?],undef,$of_id);
    my $ofids=$dbh->selectall_hashref(qq[SELECT of_id FROM out_firms WHERE of_okpo='$of_okpo' ],'of_id');
    my $ofid_str=join(',', keys %$ofids);
    
    
    
    my $ref=$dbh->selectall_arrayref(qq[SELECT dr_id,dr_amnt,dr_date,
                                               concat(of_name,'( ',of_okpo,' )') as of,
                                               a_name
                                        FROM documents_requests,out_firms,accounts
                                        WHERE 1
                                        AND dr_aid=a_id
                                        AND dr_status IN ('created','processed')
                                        AND    dr_ofid_from=of_id
                                        AND  dr_ofid_from in ($ofid_str) AND dr_fid=? 
                                        AND YEAR(dr_date)=? AND MONTH(dr_date)=?],
                                        undef,$f_id,$year,$month);
    my @res=();    
    my $size=@$ref;
    
#     unless($size){
#           $ref=$dbh->selectall_arrayref(qq[SELECT dr_id,dr_amnt,dr_date,
#                                                concat(of_name,'( ',of_okpo,' )') as of,
#                                                a_name
#                                         FROM documents_requests,out_firms,accounts
#                                         WHERE 1
#                                         AND dr_aid=a_id
#                                         AND    dr_ofid_from=of_id
#                                          AND dr_fid=? 
#                                         AND YEAR(dr_date)=? AND MONTH(dr_date)=?],
#                                         undef,$f_id,$year,$month);
# 
#     }
    foreach(@$ref){
         push @res,{dr_id=>$_->[0],
                    dr_amnt=>$_->[1],
                    dr_date=>$_->[2],
                    of=>$_->[3],
                    a_name=>$_->[4],
                    info=>$_->[2]." ".$_->[1]." ".$_->[3]." ".$_->[4]

                    };   
    }
    
    $self->{tpl_vars}->{list}=\@res;
    my $file='';
    if ($rowid){
       $file='docs4money_list2.html'; 

    }else{
         $file='docs4money_list.html';
    }
    my $tmpl=$self->load_tmpl($file);
    my $output='';
    $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
    return $output;
    

}

sub ajax_del_doc_trans
{
	my $self=shift;

	my $id=$self->query->param('id');
    my $sum=0;
	my $ref=$dbh->selectrow_hashref(q[SELECT 
    dt_infl,dr_amnt,dt_amnt,dr_id,dr_status,dr_comis,dr_comis*(dr_amnt/100) sum_comis
	FROM documents_transactions,documents_requests 
    WHERE  dr_id=dt_drid AND dt_id=?],undef,$id);	

	my $res=$dbh->do(q[UPDATE  documents_transactions SET dt_status='canceled' 
	WHERE dt_id=? 
	AND dt_status IN ('created','processed')],undef,$id);
    return 'ok'    unless($ref->{dr_id});

	if($ref->{dr_status} eq 'processed'){

        $self->query->param('param',$ref->{dr_id});
        $self->ajax_reopen_doc();

    }
	
	if(($ref->{dr_amnt}-$ref->{dt_amnt})>=-0.1&&$res eq '1'&&$ref->{dt_infl} eq 'yes'){
        
       $dbh->do(q[UPDATE documents_requests SET dr_amnt=dr_amnt-? WHERE  
          dr_id=?],undef,$ref->{dt_amnt},$ref->{dr_id});

        if(abs($ref->{dr_amnt}-$ref->{dt_amnt})<1){

                $self->query->param('id',$ref->{dr_id});
                $self->ajax_del_deal();
                return "<root>ok2!</root>";
        }

            my $sum_ref=$dbh->selectall_arrayref(q[SELECT dp_amnt,dp_id
            FROM documents_payments 
            WHERE dp_amnt IS NOT NULL
            AND dp_amnt!=0 
            AND dp_drid=?],undef,$ref->{dr_id});

            foreach my $key (@$sum_ref){
                $sum+=$key->[0];
                if($sum>$ref->{sum_comis}){

                    $self->query->param('id',$key->[1]);
                    $self->delete_document_payment();

                }

            }
           
            
        
	}
	return "<root>ok!</root>";
}


##redoned

sub ajax_reopen_doc
{
    my $self=shift;
    my $dr_id=$self->query->param('param');
    my $res=$dbh->do(q[UPDATE documents_requests SET dr_status='created' WHERE dr_id=?],undef,$dr_id);
    die "there is some races \n"    if($res ne '1');
    my $tid=$dbh->selectrow_array(q[SELECT dr_close_tid FROM documents_requests WHERE dr_id=?],undef,$dr_id);    
    return  "ok1!"    unless($tid);
   
    
    my $pays=$dbh->selectall_hashref(qq[SELECT dp_tid FROM documents_requests,documents_payments 
                                        WHERE dp_drid=dr_id AND   dr_id=$dr_id  AND 1 AND dp_tid!=0],'dp_tid');

    
 

   
    
    my $str=join(q[,],keys %$pays);    
    
    my $cols=$dbh->selectall_hashref(q[DESC accounts_reports_table],'Field');
    my @flds=sort keys %$cols;

    my $flds=join(',',@flds);

    my $sql=qq[INSERT DELAYED INTO accounts_reports_table($flds) VALUES];
    
    my $ref=$dbh->selectall_hashref(qq[SELECT $flds,concat(ct_id,ct_ex_comis_type,ct_aid) as `key` 
                                         FROM accounts_reports_table_archive 
                                         WHERE ct_id IN ($str) AND ct_ex_comis_type='transaction' ],'key');
        
    my @ar;
    my $st_tmp='';
    foreach my $t (keys %$ref){
            my $tmp=$ref->{$t};
            map{$st_tmp.="'$tmp->{$_}',"} @flds; 
            chop($st_tmp);
            push @ar,"($st_tmp)";
            $st_tmp='';
    }
    if(@ar){
            $dbh->do($sql.join(",",@ar));
    }
    
    my @del2=($tid,$self->del_trans($tid));
    
    my $del=join(q[,],@del2);    
    my $del2=join(',', keys %$pays);

    $dbh->do(qq[DELETE LOW_PRIORITY FROM  accounts_reports_table_archive 
                WHERE ct_ex_comis_type='transaction' AND  ct_id in ($del,$del2) ]);
 # for old records
    $dbh->do(qq[UPDATE accounts_reports_table SET ct_status='deleted' 
                WHERE ct_ex_comis_type='transaction' AND  ct_id in ($del) ]);

    $dbh->do(q[UPDATE documents_requests SET dr_close_tid=NULL WHERE dr_id=?],undef,$dr_id);

    return 'ok!';

}

### processed work seems good
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
        ###interesting case
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
###check the case when the docs is closed

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
    if($amnt<0||$id<0||$res ne '1'){
               die "fuck of!!delete_document_payment ";
    }
    
    
    
    my $tid = $self->del_trans($id);
    


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
    FROM documents_transactions 
    WHERE dt_drid=? AND dt_status='processed' ORDER BY dt_id ],undef,$drid);
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

    

    $res=$dbh->do(q[UPDATE 
        accounts_reports_table SET ct_status='deleted' 
        WHERE 
        ct_id in (?,?) AND ct_ex_comis_type='transaction'],undef,$id,$tid);

    $dbh->do(q[UPDATE accounts_reports_table_archive SET ct_status='deleted'  
                      WHERE ct_id in (?,?) AND ct_ex_comis_type='transaction' ],undef,$id,$tid);

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


sub add_firm{
    my $self=shift;
    my $name=$self->query->param('name');
    my $okpo=$self->query->param('okpo');
    require Encode;
    Encode::from_to($name,'utf8','cp1251');
    unless($name){
		return "Вы не ввели название фирмы!";
	}

    unless($okpo*1){
		return "Вы не ввели окпо!";
	}
	if(length($okpo)<$OKPO_MIN || length($okpo)>$OKPO_MAX){
		return "Код ОКПО должен быть длиной 8-10 символов!";
	}

   my %tmp_okpo;
   my @tmp_okpo_arr = split(//,$okpo);
   foreach my $var(@tmp_okpo_arr)
   {
		$tmp_okpo{$var}++;
   }
   return "Код ОКПО должен содержать хотя бы 3 разных цифры!" if(scalar keys %tmp_okpo<3);

    
    
    my $tmp=$dbh->selectrow_array(q[SELECT of_name FROM out_firms 
								WHERE  of_okpo=?],undef,$okpo);
	return "Уже есть такое ОКПО у фирмы $tmp" if($tmp);
	
	$tmp=$dbh->selectrow_array(q[SELECT of_id FROM out_firms 
								WHERE  of_name=?],undef,$name);
	return "Уже есть фирма c таким именем" if($tmp);


   my $res=$dbh->do(qq[INSERT into out_firms SET of_name=?,of_okpo=?,of_oid=?],undef,
    $name,$okpo,$self->{user_id});
    my $new_id =$dbh->selectrow_array(q[SELECT last_insert_id() ]);
    if($res ne '1'){
        die "something wrong \n";
    
    }else{
        return "[ok]$new_id,,,$okpo,,,$name";
    }

}




sub get_right
{
	return 'index';
}

1;
