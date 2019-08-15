#!/usr/bin/perl
use Storable qw( &thaw &freeze);
use strict;
use lib q[./];
use SiteDB;

my $sth=$dbh->prepare(q[SELECT * FROM reports_without_back WHERE  cr_id>=50 AND cr_id<71 AND cr_status='created' ORDER BY cr_id DESC ]);
my $DELTA_W;
$DELTA_W=769;
my $avail_currency={USD=>'a_usd',UAH=>'a_uah',EUR=>'a_eur'};

$sth->execute();
my $transactions;
my ($tmp_u,$tmp_e,$tmp_h);
my ($of_u,$of_e,$of_h);
my @tids;
while(my $r=$sth->fetchrow_hashref())
{

#	die 'here';	
	my %params = %{thaw($r->{cr_xml_detailes})};
	$transactions.=$r->{cr_tids}.',';
	
	$tmp_u=$params{master_cards}->[0]->{USD};
	$tmp_e=$params{master_cards}->[0]->{EUR};
	$tmp_h=$params{master_cards}->[0]->{UAH};
	
		
	$of_u=$params{master_cards}->[1]->{USD};
	$of_e=$params{master_cards}->[1]->{EUR};
	$of_h=$params{master_cards}->[1]->{UAH};
	
	$tmp_e=~s/[ ]//g;
	$tmp_u=~s/[ ]//g;
	$tmp_h=~s/[ ]//g;
	
	$of_u=~s/[ ]//g;
	$of_e=~s/[ ]//g;
	$of_h=~s/[ ]//g;
	use Data::Dumper;
#	die $params{delta_uah};

	$params{delta_uah}=($params{work_money_uah}-$tmp_h)-$params{last_sum_exc}->{last_sum_exc_uah};
	$params{delta_usd}=($params{work_money_usd}-$tmp_u)-$params{last_sum_exc}->{last_sum_exc_usd};
	$params{delta_eur}=($params{work_money_eur}-$tmp_e)-$params{last_sum_exc}->{last_sum_exc_eur};

	my %percents=(766=>0.5,767=>0.25,768=>0.25);

	my %keys=(delta_usd=>'USD',delta_uah=>'UAH',delta_eur=>'EUR');

	my %of=(USD=>$of_u,UAH=>$of_h,EUR=>$of_e);
	
	foreach my $key1( keys %keys )
	{


			
		foreach my $key2 (keys %percents)
		{
			push @tids,add_trans({
				t_name1 =>$DELTA_W,
				t_name2 =>$key2, 
				t_currency => $keys{$key1},
				t_amnt =>$params{$key1} * $percents{$key2} ,
				t_comment =>"Распределение доходов между  основными карточками $params{date}",
				t_status=>'system',
       			});
		
   			push @tids,add_trans({
				t_name1 =>765,
				t_name2 =>$key2,
				t_currency =>$keys{$key1},
				t_amnt =>$of{$keys{$key1}} * $percents{$key2},
				t_comment =>"Распределение затрат  $params{date}",
				t_status=>'system',
     			});
		}
		
	}
	$dbh->do(q[UPDATE reports_without_back SET 
		cr_delta_usd=?,cr_delta_uah=?,cr_delta_eur=?,cr_xml_detailes=?,cr_tids=? 
		WHERE
		 cr_id=?],undef,
		$params{delta_usd},
		$params{delta_uah},
		$params{delta_eur},
		freeze(\%params),join(',',@tids),$r->{cr_id});
	@tids=();
	
	
		


}



print "$transactions\n";

sub add_trans
{
        my ($ref)=@_;
	
	$ref->{t_oid}=2;
	$ref->{o_login}='mysterio';
        die "Такого пользователя нет в системе \n" unless($ref->{t_name1});
	$ref->{t_status}='no' unless($ref->{t_status});
        
	
	 $ref->{t_aid1}=$ref->{t_name1};
#my $a2=$dbh->selectrow_array(q[SELECT a_id FROM accounts WHERE a_id=? ],undef,$ref->{t_name2});

	die "Такого пользователя нет в системе \n"  unless($ref->{t_name2});
        
	$ref->{t_aid2}=$ref->{t_name2};

		

        my $field=$avail_currency->{$ref->{t_currency}};
        $ref->{account_bill}=$field;
	
        die "Такого счета нет \n" unless($field);
        
	$ref->{t_amnt}=~s/[,]/\./g;
	$ref->{t_amnt}=~s/[ \"\']//g;
	
        die "Сумма не соостветсвует формату числа\n" unless($ref->{t_amnt}=~/[\-]{0,1}\d+\.{0,1}\d{0,2}/);
        
	($ref->{sum_before2},$ref->{a_name2})=$dbh->selectrow_array(qq[SELECT $field,a_name 
	FROM accounts WHERE a_id=? ],undef,$ref->{t_name2});   
	($ref->{sum_before1},$ref->{a_name1})=$dbh->selectrow_array(qq[SELECT $field,a_name
	FROM accounts WHERE a_id=? ],undef,$ref->{t_name1});     
	
        die "Пожайлуста заполните поле комментариев \n" if(!$ref->{t_comment});

        $dbh->{AutoCommit} = 0;  # enable transactions, if possible
        $dbh->{RaiseError} = 1;
        my $t_id;

        eval {
                $t_id=do_trans($ref);       # and updates
                $dbh->commit;
                $dbh->{AutoCommit} = 1;   # commit the changes if we get this far
	};
        if ($@) {
                warn "Transaction aborted because $@";
                my $qwe = "$@";
# now rollback to undo the incomplete changes
# but do it in an eval{} as it may also fail
                eval { $dbh->rollback };
		my $r=$dbh->errstr;
                die "Внутренняя ошибка системы обратитесь к разработчику: code 4 ($qwe)\n"; 
# add other application on-error-clean-up code here
}
        return $t_id;   



}
sub do_trans
{
        my $ref=shift;
      
        my $res=$dbh->do(qq[UPDATE accounts SET $ref->{account_bill}=$ref->{account_bill}+? WHERE 
        a_id=$ref->{t_aid1}   ],undef,-1*$ref->{t_amnt}); 

        die "Внутренняя ошибка системы обратитесь к разработчику : code 1\n" unless($res eq 1);

         my $t_id=1;
       
         $res=$dbh->do(q[INSERT 
	 INTO
 	 transactions(t_ts,t_aid1,t_aid2,t_amnt,t_currency,t_comment,t_oid,t_status,
	t_amnt_before1,t_amnt_before2) 
	 VALUES(current_timestamp,?,?,?,?,?,?,?,?,?)],undef,
	  @$ref{qw( t_aid1 t_aid2 t_amnt t_currency  t_comment t_oid t_status sum_before1 sum_before2)});
          die "Внутренняя ошибка системы обратитесь к разработчику : code 2\n" unless($res eq 1);   
          $t_id=$dbh->selectrow_array(q[SELECT last_insert_id()]);
	  if($ref->{t_status} eq 'system')
	  {
	
		$dbh->do(q[INSERT INTO accounts_reports_table(
		ct_id,ct_aid,ct_comment,ct_oid,o_login,ct_fid,f_name,ct_amnt,
		ct_currency,result_amnt,ct_date,e_currency2,ct_ex_comis_type,ts,ct_status
		)
		  VALUES(?,?,?,?,?,?,?,?,?,?,current_timestamp,?,
		'transaction',current_timestamp,'processed')],undef,$t_id, 
		@$ref{qw( t_aid2  t_comment t_oid o_login t_aid1 a_name1 t_amnt t_currency t_amnt t_currency)});
		
		$ref->{t_amnt}=-1*$ref->{t_amnt};
		$dbh->do(q[INSERT INTO accounts_reports_table(
		ct_id,ct_aid,ct_comment,ct_oid,o_login,ct_fid,f_name,ct_amnt,
		ct_currency,result_amnt,ct_date,e_currency2,ct_ex_comis_type,ts,ct_status
		)  VALUES(?,?,?,?,?,?,?,?,?,?,
		current_timestamp,?,'transaction',current_timestamp,'processed')],undef,$t_id, 
		@$ref{qw( t_aid1  t_comment t_oid o_login t_aid2 a_name2 t_amnt t_currency t_amnt t_currency)});
		$ref->{t_amnt}=-1*$ref->{t_amnt};


	  }


        $res=$dbh->do(qq[UPDATE accounts SET $ref->{account_bill}=$ref->{account_bill}+? WHERE 
        a_id=$ref->{t_aid2}],undef,$ref->{t_amnt});
        die "Внутренняя ошибка системы обратитесь к разработчику : code 3\n" unless($res eq 1);
        
        return $t_id ;


}    

