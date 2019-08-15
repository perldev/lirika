#!/usr/bin/perl
use MyConfig;
use lib $MyConfig::path;
use SiteDB;
use CGIBase;
use SiteCommon;
use strict;
my $NEW_DOC=1386;
database_connect();
my $ref=$dbh->selectall_arrayref(q[SELECT 
				   dp_tid,dp_id,dp_drid 
				   FROM 
				   documents_requests,
				   documents_payments  
				   WHERE 
				   dp_drid=dr_id AND dr_status='created' AND dp_tid>0 ]);

print "begin updating the normal office \n";
foreach my $t (@$ref){
    my $tmp=$dbh->selectrow_hashref(q[SELECT * FROM transactions WHERE t_id=?],undef,$t->[0]);
   
    my $del_id=CGIBase::do_trans({
		       account_bill=>$avail_currency->{ $tmp->{t_currency} },
		       t_aid1=>$tmp->{t_aid2},
		       t_aid2=>$tmp->{t_aid1},
		       t_amnt=> $tmp->{t_amnt},
		       t_currency=>$tmp->{t_currency},
		       t_comment=>'Óäàëåíèå '.$tmp->{t_comment},
		       t_oid=>2,
		       t_status=>$tmp->{t_status},
		       del_status=>$tmp->{del_status},
		       sum_before1=>0,
		       sum_before2=>0
		      });
    $dbh->do(qq[UPDATE accounts_reports_table 
		SET ct_status='deleted' 
		WHERE ct_id IN ($del_id,$tmp->{t_id}) AND ct_ex_comis_type='transaction']);
    
    my $new_tid=CGIBase::do_trans({
		       account_bill=>$avail_currency->{ $tmp->{t_currency} },
		       t_aid1=>$tmp->{t_aid1},
		       t_aid2=>$NEW_DOC,
		       t_amnt=> $tmp->{t_amnt},
		       t_currency=>$tmp->{t_currency},
		       t_comment=>$tmp->{t_comment},
		       t_oid=>2,
		       t_status=>$tmp->{t_status},
		       del_status=>$tmp->{del_status},
		       sum_before1=>0,
		       sum_before2=>0
		      });
    $dbh->do(q[UPDATE documents_payments SET dp_tid=? WHERE dp_id=?],undef,$new_tid,$t->[1]);
}
print "stating work on unnormal transactions \n";
my $sth=$dbh->prepare(q[SELECT * FROM transfers WHERE  YEAR(t_date)=2011  
						AND 6217  IN (t_aid1,t_aid2)  AND t_id NOT IN 
						(SELECT dp_tid 
						 FROM documents_requests,documents_payments  
						 WHERE dp_drid=dr_id AND dr_status='created' AND dp_tid>0)]);
$sth->execute();
while(my $tmp=$sth->fetchrow_hashref()){
      

      my $del_id=CGIBase::do_trans({
		       
		       account_bill=>$avail_currency->{ $tmp->{t_currency} },
		       t_aid1=>$tmp->{t_aid2},
		       t_aid2=>$tmp->{t_aid1},
		       t_amnt=> $tmp->{t_amnt},
		       t_currency=>$tmp->{t_currency},
		       t_comment=>'Óäàëåíèå '.$tmp->{t_comment},
		       t_oid=>2,
		       t_status=>'no',
		       del_status=>'deleted',
		       sum_before1=>0,
		       sum_before2=>0

		      });
	$tmp->{t_aid2}=$NEW_DOC   if($tmp->{t_aid2}==6217);
	$tmp->{t_aid1}=$NEW_DOC   if($tmp->{t_aid1}==6217);

	CGIBase::do_trans(
		       {
		       account_bill=>
		       $avail_currency->{ $tmp->{t_currency} },
		       t_aid1=>$tmp->{t_aid1},
		       t_aid2=>$tmp->{t_aid2},
		       t_amnt=> $tmp->{t_amnt},
		       t_currency=>$tmp->{t_currency},
		       t_comment=>$tmp->{t_comment},
		       t_oid=>2,
		       t_status=>'system',
		       del_status=>'processed',
		       sum_before1=>0,
		       sum_before2=>0
		       }
		      );

      $dbh->do(qq[UPDATE accounts_reports_table SET ct_status='deleted' 
		  WHERE 
		  ct_id IN ($del_id,$tmp->{t_id}) 
		  AND 
		  ct_ex_comis_type='transaction']);

      $dbh->do(q[UPDATE accounts_transfers SET  at_status='deleted',at_tid_back=? WHERE at_id=?],undef,
      $del_id,
      $tmp->{at_id});
      



}

