#!/usr/bin/perl
use strict;
use warnings;


use MyConfig;
use lib $MyConfig::path;
use SiteDB;
use CGIBase;
use LWP::UserAgent;


my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");
database_connect();
my $session='hervam20286';
#$dbh->do(q[optimize table cashier_transactions]);
#$dbh->do(q[optimize table transactions]);      
#$dbh->do(q[optimize table accounts_reports_table]); 
my $rr=$dbh->selectall_hashref(q[SELECT accounts_reports_table.ct_id as id
			 FROM cashier_transactions, out_firms,accounts_reports_table 
			 WHERE accounts_reports_table.ct_id=cashier_transactions.ct_id 
			AND (cashier_transactions.ct_aid=667 OR 1)
			AND ct_ofid=of_id AND ct_ofid IS NOT NULL AND cashier_transactions.ct_status='processed' 
			AND ct_ofid!=0 AND accounts_reports_table.ct_ex_comis_type='input' 
			AND (length(accounts_reports_table.ct_comment)<length(of_name) OR 1 )],'id');

foreach(keys %$rr){
	my ($of_name,$a_name)=$dbh->selectrow_array(q[SELECT of_name,a_name FROM cashier_transactions,out_firms,accounts 
					    WHERE  of_id=ct_ofid AND ct_ofid IS NOT NULL AND ct_ofid!=0  AND ct_aid=a_id AND ct_id=? ],undef,$_);
	$dbh->do(q[UPDATE accounts_reports_table SET ct_comment=concat(?,'  ',ct_comment) 
		  WHERE ct_ex_comis_type='input' AND ct_id=?],undef,$of_name,$_);
	



}








exit(0);
$dbh->do(qq[INSERT INTO  oper_sessions SET 
    os_session='$session',
    os_oid=2,
    os_created=current_timestamp,
    os_expired=date_add(current_timestamp,interval 4 hour),
    os_ip='127.0.0.1'
    ]);
my $id=$dbh->selectrow_array(q[SELECT last_insert_id() ]);
our $TIMER;
$TIMER  = RHP::Timer->new();
$TIMER->start('fizzbin');



my $sth=$dbh->prepare(q[SELECT 
                        ct_amnt,ct_tid,ct_id,ct_status
                        FROM 
                        cashier_transactions 
                       WHERE ct_aid=409 AND ct_fid=-1 
		        AND ct_status 
                        IN ('processed','returned')
                        AND ct_amnt>=500000
                       ]);




$sth->execute();
my $self={o_id=>2,o_login=>2};

while(my $row=$sth->fetchrow_hashref()){

    my $ref=$dbh->selectrow_hashref(q[SELECT * 
                                      FROM 
                                      transactions 
                                      WHERE t_id=?],undef,$row->{ct_tid});


     CGIBase::add_trans($self,
                    {
                        t_name1 => $ref->{t_aid2},
                        t_name2 => $ref->{t_aid1},
                        t_currency => $ref->{t_currency},
                        t_amnt => $ref->{t_amnt},
                        t_comment => "deleting $ref->{t_comment}",               
                        t_status=>$ref->{t_status},

                    });





  
       my $id1=CGIBase::add_trans($self,
                    {
                        t_name1 =>$ref->{t_aid1} ,
                        t_name2 => 3673 ,
                        t_currency => $ref->{t_currency},
                        t_amnt => $ref->{t_amnt},
                        t_comment => "$ref->{t_comment}",               
                        t_status=>$ref->{t_status},

                    });
     print "\n";
     $dbh->do(q[UPDATE cashier_transactions SET ct_aid=?,ct_tid=? WHERE ct_id=?],undef,3673,$id1,$row->{ct_id});

     $dbh->do(q[UPDATE accounts_reports_table SET ct_aid=?  
		WHERE ct_ex_comis_type='input' 
		AND ct_aid=? 
		AND ct_id=?],undef,3673,$ref->{t_aid2},$row->{ct_id});
     print "\n";
#     $dbh->do(q[UPDATE accounts_reports_table SET ct_fid=?  WHERE ct_fid=? AND ct_id=?],undef,3673,$ref->{t_aid2},$row->{ct_id});


    foreach(keys %$row){
            print "$_=>$row->{$_},";
    }
    print " \n";



}
$sth->finish();
exit(0);


$sth=$dbh->prepare(q[SELECT 
                        ct_amnt,ct_tid,ct_id,ct_comment,ct_ts2
                        FROM 
                        cashier_transactions 
                        WHERE ct_aid=409 AND ct_fid>0 
                        AND lcase(ct_comment) like '%сигма%' 
                        AND lcase(ct_comment) like '%касса%'
                        AND ct_status='processed'
                        AND ct_amnt<0
                       ]);
$sth->execute();
while(my $r=$sth->fetchrow_hashref()){
  my $req = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/ajax.cgi');
  $req->content_type('application/x-www-form-urlencoded');
  $req->content(qq[do=back_firm_req&id=$r->{ct_id}&ajax=1&session=$session]);
  my $res = $ua->request($req);
  # Check the outcome of the response
  my $new_id;
  if ($res->is_success) {
      print $res->content;
      $new_id=int($res->content);
  }else{
    next ;
  }
    next unless($new_id);
    my $ct_aid=3673;

    my $req1 = HTTP::Request->new(POST => 'http://localhost:8081/cgi-bin/firm_output.cgi'); 
    $req1->content_type('application/x-www-form-urlencoded');
    $req1->content(qq[do=edit&action=apply&ct_ts2=$r->{ct_ts2}&ct_comment=$r->{ct_comment}&__confirm=1&ct_aid=$ct_aid&id=$new_id&ct_id=$new_id&ajax=1&session=$session]);
    $res = $ua->request($req1);
    print $res->content;  
  # Check the outcome of the response
    print "process $new_id \n";
}
$sth->finish();
my $time=$TIMER->stop;
$dbh->do(q[DELETE FROM oper_sessions WHERE os_id=?],undef,$id);






# open(FL,">>/tmp/mail_log") or die $!;
print  "time of mail   the time $time s";

