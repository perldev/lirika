package WorkingWindow;
use strict;
use SiteDB;
use SiteConfig;
use SiteCommon;
sub get_working_window
{
	my ($id,$ts)=@_;
	my $id_new=$dbh->selectrow_array(q[SELECT 
					   a_aid_parent
					   FROM accounts 
					   WHERE a_id=? AND a_status='active'],undef,$id);
	
	return {table=>'accounts_reports_table'} unless($id_new);
	
	
}


sub get_start_amnts
{
	
	my $fid=shift;

#return {USD=>$USERS_HASH->{$fid}} if($USERS_HASH->{$fid});
	
# 	return {} if(is_root_account($fid));
	
	my $ref=get_account_info($fid);

	my $sum={USD=>$ref->{a_usd},UAH=>$ref->{a_uah},EUR=>$ref->{a_eur}};

	my $sum1=get_from_history($fid);

	foreach( keys %RATE_FORMS)
	{
		$sum->{$_}+=$dbh->selectrow_array(q[SELECT sum(t_amnt) FROM transactions 
		WHERE   t_aid1=?  
		AND t_currency=? AND t_ts>? AND del_status!='deleted'],undef,$fid,$_,$sum1->{ah_ts});

		$sum->{$_}-=$dbh->selectrow_array(q[SELECT sum(t_amnt) FROM transactions WHERE 
		t_aid2=?  AND t_currency=? AND t_ts>? AND del_status!='deleted'],undef,$fid,$_,$sum1->{ah_ts});
	
	}
	return $sum;
	



}
sub get_archive
{
	my ($ts,$aid)=@_;
	
	return ($dbh->selectrow_hashref(q[SELECT ah_id,ah_ts 
	FROM accounts_history 
	WHERE ah_ts>? AND ah_aid=? ORDER BY ah_id ASC LIMIT 1 ],undef,$ts,$aid),$dbh->selectrow_hashref(q[SELECT ah_id,ah_ts 
	FROM accounts_history 
	WHERE ah_ts<? AND ah_aid=? ORDER BY ah_id DESC LIMIT 1 ],undef,$ts,$aid));



}


sub get_from_history
{
	my $fid=shift;
	return $dbh->selectrow_hashref(q[SELECT 
					ah_usd AS USD,
					ah_eur AS EUR,
					ah_uah AS UAH,
					ah_ts as ts
					FROM accounts_history 
		WHERE ah_aid=? ORDER BY ah_id DESC LIMIT 1],undef,$fid);
}

sub restore_working_window{

    my $aid=shift;
#   my $res=$dbh->do(q[UPDATE accounts SET a_status='deleted' WHERE a_id=? AND a_status!='deleted'],undef,$id);
#   return undef if($res ne 1);
      
        
        
    my $cols=$dbh->selectall_hashref(q[DESC accounts_reports_table],'Field');

    my $flds=join(',',sort keys %$cols);
    
    my $a_info=get_account_info($aid);
    my $ah_id=$dbh->selectrow_array(q[SELECT max(ah_id) as ah_id FROM accounts_history
      WHERE ah_aid=? AND  ah_status!='deleted'],undef,$aid);
    return  0 unless($ah_id);
    my $res=$dbh->do(q[UPDATE accounts_history SET ah_status='deleted' WHERE ah_id=?],undef,$ah_id);
    return 0     unless($res eq '1');

    my $found_rows=$dbh->selectrow_array(qq[SELECT count(*) FROM accounts_reports_table_archive 
    WHERE  ah_id=?],undef,$ah_id);

    $found_rows=int($found_rows/$ARCHIVE_WORKING_WINDOW)*$ARCHIVE_WORKING_WINDOW+$ARCHIVE_WORKING_WINDOW*(!!($found_rows % $ARCHIVE_WORKING_WINDOW));
    
   
    my $tmp=0;
    my @delete;
    for(my $i=0;$i<=$found_rows;$i+=$ARCHIVE_WORKING_WINDOW)
    {
        
        my $sth=$dbh->prepare(qq[SELECT $flds FROM accounts_reports_table_archive 
        WHERE   is_archive_status='no' AND ah_id=?  ORDER BY ts ASC LIMIT $ARCHIVE_WORKING_WINDOW]);

        $sth->execute($ah_id);
    

        $dbh->do(qq[UPDATE accounts_reports_table_archive SET is_archive_status='yes' 
        WHERE   is_archive_status='no' AND  ah_id=? 
        ORDER BY ts 
        ASC LIMIT $ARCHIVE_WORKING_WINDOW],undef,$ah_id);

        my $sql=qq[INSERT DELAYED INTO accounts_reports_table($flds) VALUES];
    
        my $sql_d=qq[DELETE LOW_PRIORITY FROM  accounts_reports_table_archive WHERE 
         ah_id=$ah_id AND is_archive_status='yes' AND (];
         my  $ii=0;
         my $r;
          while($r=$sth->fetchrow_hashref()){
                my @arr;
                
                foreach( sort keys %$r){
                    $r->{$_}=~s/(['\\])/\\$1/g;
                    push @arr,"'$r->{$_}'";
                } 

                $sql.="(";
                $sql.=join(',',@arr);       
                $sql.="),";

                $sql_d.="( ct_ex_comis_type='$r->{ct_ex_comis_type}' AND ct_id=$r->{ct_id} ) OR ";
                $ii++;
        #       push @ids,{ct_ex_comis_type=>$r->{ct_ex_comis_type},ct_id=>$r->{ct_id}};
            }

            if($ii){
                $sql_d.=' 0 )';
                chop($sql);
                $dbh->do($sql);
                push @delete,$sql_d;
            }

            $sth->finish();
    }

    foreach(@delete){
        $dbh->do($_);
    }

    


    return $found_rows;



}

sub save_working_window
{
	my ($id,$ts,$iscols,$oid)=@_;
# 	my $res=$dbh->do(q[UPDATE accounts SET a_status='deleted' WHERE a_id=? AND a_status!='deleted'],undef,$id);
# 	return undef if($res ne 1);

#     if(defined $iscols){
#          
#          $iscols=" col_status='yes' " ;
#         
#     }else{

         $iscols=" 1 " ;

#     }


	my $cols=$dbh->selectall_hashref(q[DESC accounts_reports_table],'Field');

	my $flds=join(',',sort keys %$cols);
	
   my $a_info=get_account_info($id);
    
   return  if(!$a_info->{a_id}||$ts!~/\d\d\d\d-\d\d-\d\d/);
   $ts="$ts 23:59:59";
    
   my $sums=calculate_sum_with(
                {
                    a_id=>$id,
                    date2=>" ts>'$ts' ",
                    date1=>' 1 ',   
                }
                );
     
 
        $a_info->{a_uah}=($a_info->{a_uah}-$sums->{UAH});
        $a_info->{a_usd}=($a_info->{a_usd}-$sums->{USD});
        $a_info->{a_eur}=($a_info->{a_eur}-$sums->{EUR});
        $dbh->do(q[
		INSERT INTO accounts_history
		(
        ah_aid,
		ah_uah,
		ah_usd,
		ah_eur,
		ah_oid,
		ah_acid,
        ah_ts) 
		VALUES(?,?,?,?,?,?,?)
		],undef,$id,
		$a_info->{a_uah},
		$a_info->{a_usd},
		$a_info->{a_eur},
		$oid,
		$a_info->{a_acid},
        $ts
		);
	

    my $ah_id=$dbh->selectrow_array(q[SELECT last_insert_id()]);
     
    my $found_rows=$dbh->selectrow_array(qq[SELECT count(*) FROM accounts_reports_table 
    WHERE  ts<'$ts' AND  ct_aid=?],undef,$id);

    $found_rows=int($found_rows/$ARCHIVE_WORKING_WINDOW)*$ARCHIVE_WORKING_WINDOW+$ARCHIVE_WORKING_WINDOW*(!!($found_rows % $ARCHIVE_WORKING_WINDOW));
    
 
    my $tmp=0;
    my @delete;
    for(my $i=0;$i<=$found_rows;$i+=$ARCHIVE_WORKING_WINDOW)
    {

        my $sth=$dbh->prepare(qq[SELECT $flds FROM accounts_reports_table 
        WHERE  ts<'$ts' AND  ct_aid=? 
        AND is_archive_status!='yes' AND $iscols
        ORDER BY ts LIMIT $ARCHIVE_WORKING_WINDOW]);

        $sth->execute($id);
    

        $dbh->do(qq[UPDATE accounts_reports_table SET is_archive_status='yes' 
        WHERE  ts<'$ts' 
        AND  ct_aid=? AND $iscols 
        AND  is_archive_status!='yes' 
        ORDER BY ts LIMIT $ARCHIVE_WORKING_WINDOW],undef,$id);

    
    
        my $sql=qq[INSERT DELAYED INTO accounts_reports_table_archive($flds,ah_id) VALUES];
    
	    my $sql_d=qq[DELETE LOW_PRIORITY FROM  accounts_reports_table WHERE 
         ct_aid=$id AND is_archive_status='yes' AND $iscols AND (];
	    
        my  $ii=0;
        
    
        
            my $r;
	      while($r=$sth->fetchrow_hashref()){
		        my @arr;
		        
		        foreach( sort keys %$r){
		            $r->{$_}=~s/(['\\])/\\$1/g;
		            push @arr,"'$r->{$_}'";
		        } 
		        $sql.="(";
		        $sql.=join(',',@arr);		
		        $sql.=",$ah_id),";
		        $sql_d.="( ct_ex_comis_type='$r->{ct_ex_comis_type}' AND ct_id=$r->{ct_id} ) OR ";
		        $ii++;
        # 		push @ids,{ct_ex_comis_type=>$r->{ct_ex_comis_type},ct_id=>$r->{ct_id}};
	        }

            if($ii){
	            $sql_d.=' 0 )';
	            chop($sql);
	            $dbh->do($sql);
                push @delete,$sql_d;
            }

            $sth->finish();
    }

    foreach(@delete){
        $dbh->do($_);
    }
###it so bad that this request is here ((

    


	return $found_rows;


}

sub get_account_info
{
	my $id=shift;
	return $dbh->selectrow_hashref(q[SELECT * FROM accounts WHERE a_id=?],undef,$id);

}



1;