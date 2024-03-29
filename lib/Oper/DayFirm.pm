package Oper::DayFirm;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;

sub setup
{
  my $self = shift;
  $self->start_mode('list');
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'print_list'=>'list'

  );
}
sub get_right
{       
    my $self=shift;
	my $resident=$self->query->param('resident');
	unless($resident)
	{
		return 'all_firms';
	}else
	{
		return 'du';
	}
}
sub list
{
	my $self=shift;
	my $date=$self->query->param('date');
	my $resident=$self->query->param('resident');

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
	$year+=1900;
	$mon+=1;
	
	my ($current_year,$current_mon,$current_day)=($year,$mon,$mday); 

	if(!defined($date)||$date!~/\d{4}-\d{2}-\d{2}/)
	{
		$date="$year-$mon-$mday";
	
	}else
	{
	       ($current_year,$current_mon,$current_day)=split('-',$date);
		
	}




my $sql;

	unless($resident)
	{
		$sql=qq[SELECT f_name,f_id,f_uah,f_usd,f_eur 
		FROM firms WHERe  f_status='active' AND f_id>0 AND ( (abs(f_usd)>0.001 OR 
		abs(f_eur)>0.001) OR (abs(f_usd)<0.01 AND 
		abs(f_eur)<0.001 AND abs(f_uah<0.01)) ) GROUP BY f_id ];
	}else
	{
		$sql=qq[SELECT f_name,f_id,f_uah,f_usd,f_eur FROM firms WHERe  f_status='active' AND f_id>0 AND (abs(f_uah)>0.001  
		OR (abs(f_usd)<0.01 AND 
		abs(f_eur)<0.001 AND abs(f_uah<0.01)) )

		GROUP BY f_id ];
	}

	my $hash=$dbh->selectall_hashref($sql,'f_id');
	
	

	$sql=qq[SELECT ct_fid,sum(IF(ct_currency='UAH',ct_amnt,0)) AS 'UAH',sum(IF(ct_currency='USD',ct_amnt,0)) 
	AS 'USD',sum(IF(ct_currency='EUR',ct_amnt,0)) as 'EUR',ct_aid 
	FROM cashier_transactions  WHERE ct_date>='$date' 
	AND ct_req='no'  AND ct_status!='deleted' AND ct_fid>0 GROUP BY ct_fid;
	];

	my $accounts=$dbh->selectall_hashref(q[SELECT a_id,a_name FROM accounts WHERE a_status='active'],'a_id');

	my $hash1=$dbh->selectall_hashref($sql,'ct_fid');
	
	$sql=qq[SELECT ct_fid,sum(IF(ct_currency='UAH',ct_amnt,0)) AS 'R_UAH',sum(IF(ct_currency='USD',ct_amnt,0)) 
	AS 'R_USD',sum(IF(ct_currency='EUR',ct_amnt,0)) as 'R_EUR' FROM cashier_transactions WHERE 1
	AND ct_req='yes' AND ct_status!='deleted' AND ct_fid>0 GROUP BY ct_fid;
	];
	my $hash2=$dbh->selectall_hashref($sql,'ct_fid');
	
	foreach my $key ( keys %{ $hash1 })
	{
		map{ $hash->{$key}->{$_}=$hash1->{$key}->{$_} if($hash->{$key}) }  keys %{ $hash1->{$key} }  ;
			
	}	
	foreach my $key ( keys %{ $hash2 })
	{
		map{ $hash->{$key}->{$_}= $hash1->{$key}->{$_} if($hash->{$key}) } keys %{ $hash2->{$key} }  ;
			
	}		

	my @keys= sort { $hash->{$a}->{f_name} cmp $hash->{$b}->{f_name} } keys %$hash;


    my $now=1*$current_year>=1*$year&&(1*$current_mon>=1*$mon||1*$current_year>=1*$year)
	&&(1*$current_day>=1*$mday||$current_mon*1>1*$mon||1*$current_year>1*$year);
	

	my $prew=undef;	
	map {$hash->{$_}->{'R_UAH'}=$hash->{$_}->{'R_USD'}=$hash->{$_}->{'R_USD'}=0 } keys %{ $hash };

	if($now)
	{	
		

		$sql=qq[
		SELECT ct_amnt,ct_currency,ct_req,ct_status,ct_comment,ct_id,ct_fid,ct_ts,ct_aid,
		col_status
		FROM 
		cashier_transactions
		WHERE ct_date=?  AND ct_status!='deleted' 
		AND   ct_fid>0
		ORDER BY ct_fid,ct_currency,ct_req DESC,ct_ts ASC];	
	}else
	{
		$sql=qq[SELECT ct_amnt,ct_currency,ct_req,ct_status,ct_comment,ct_id,ct_fid,ct_ts,ct_aid,col_status
		FROM 
		cashier_transactions
		WHERE 
		ct_date=?
		AND ct_fid>0 AND 
		ct_req='no' AND ct_status!='deleted'
		ORDER BY ct_fid,ct_currency,ct_ts ASC
		];
	}
	$date=~s/[' "\\]//g;
	my $payments_usd=$dbh->selectall_hashref(qq[SELECT nrp_id,nrp_ctid,ct_fid,sum(nrp_number) as count
		 FROM non_resident_payments,cashier_transactions 
		WHERE nrp_date='$date' AND ct_currency='USD' 
		AND nrp_ctid=ct_id  GROUP BY ct_fid],'ct_fid');
	my $payments_eur=$dbh->selectall_hashref(qq[SELECT nrp_id,nrp_ctid,ct_fid,sum(nrp_number) as count
		 FROM non_resident_payments,cashier_transactions 
		WHERE nrp_date='$date' AND ct_currency='EUR' 
		AND nrp_ctid=ct_id  GROUP BY ct_fid ],'ct_fid');

	
	my $i;
	my $ref=$dbh->selectall_arrayref($sql,undef,$date);
	my $size=@$ref;
	my @res;
	my $s;
	#die Dumper \@keys;
	my $pays_count_u;
	my $pays_count_e;
	foreach(@keys)	
	{
		my $i=find_first_input($ref,$_);
		my %hash=( 'UAH'=>$hash->{$_}->{f_uah}-$hash->{$_}->{UAH},
		'USD'=>$hash->{$_}->{f_usd} -$hash->{$_}->{USD},'EUR'=>$hash->{$_}->{f_eur} -$hash->{$_}->{EUR} );	
		my $first={
			   f_name=>$hash->{$_}->{f_name},
			   f_id=>$_,
			   type=>'begin',
			   unformat_uah_beg=>$hash{UAH},
			   unformat_usd_beg=>$hash{USD},
			   unformat_eur_beg=>$hash{EUR},
			   UAH_BEG=>format_float($hash{UAH} ),
			   USD_BEG=>format_float($hash{USD} ),
			   EUR_BEG=>format_float($hash{EUR} ),
			   unformat_uah_fin=>$hash{UAH},
			   unformat_usd_fin=>$hash{USD},
			   unformat_eur_fin=>$hash{EUR},
			   UAH_FIN=>format_float($hash{UAH} ),
			   USD_FIN=>format_float($hash{USD} ),
			   EUR_FIN=>format_float($hash{EUR} )
			  };
		push @res,$first;
		my $req_sums={USD=>0,EUR=>0,UAH=>0};
		$pays_count_u=0;
		$pays_count_e=0;
		for(;$i>=0&&$i<$size&&$ref->[$i]->[6]==$_;$i++)
		{
		
			push @res,{ 
					ct_id=>$ref->[$i]->[5],
					ct_status=>$ref->[$i]->[3],
					ct_aid=>$ref->[$i]->[8],
					a_name=>$accounts->{$ref->[$i]->[8]}->{a_name},
					type=>'operation',
					currency=>$ref->[$i]->[1],
					non_format_amnt=>$ref->[$i]->[0],
					amnt=>format_float($ref->[$i]->[0]),
					req=>$ref->[$i]->[2] ne 'yes',
# 					ct_status=>$MAIN_STATUSES{$ref->[$i]->[3]},
					ct_comment=>$ref->[$i]->[4],
					ct_ts=>format_date($ref->[$i]->[7]),
					ct_col_status=>$ref->[$i]->[9] eq 'yes',	 
	
				   };
			$req_sums->{$ref->[$i]->[1]}+=$ref->[$i]->[0] if($ref->[$i]->[0]<0);
			$hash{$ref->[$i]->[1]}+=$ref->[$i]->[0];
			
			$pays_count_u+=($ref->[$i]->[0]<0&&$ref->[$i]->[2] ne 'yes'&&$ref->[$i]->[3] ne 'transit'&&$ref->[$i]->[1] eq 'USD');
			$pays_count_e+=($ref->[$i]->[0]<0&&$ref->[$i]->[2] ne 'yes'&&$ref->[$i]->[3] ne 'transit'&&$ref->[$i]->[1] eq 'EUR');
			
		
		}
		
		$first->{unformat_sum_uah}=$req_sums->{UAH};
		$first->{unformat_sum_usd}=$req_sums->{USD};
		$first->{unformat_sum_eur}=$req_sums->{EUR};
		
		$first->{SUM_UAH_REQ}=format_float($req_sums->{UAH});
		$first->{SUM_USD_REQ}=format_float($req_sums->{USD});
		$first->{SUM_EUR_REQ}=format_float($req_sums->{EUR});
		$first->{UAH_FIN}=format_float($hash{UAH});
		$first->{USD_FIN}=format_float($hash{USD});
		$first->{EUR_FIN}=format_float($hash{EUR});
		$first->{p_count_e}=$pays_count_e-$payments_eur->{$_}->{count};
		$first->{p_count_u}=$pays_count_u-$payments_usd->{$_}->{count};
	
		$first->{is_payments}=$first->{p_count_e}||$first->{p_count_u};

		$first->{unformat_uah_fin}=$hash{UAH};
		$first->{unformat_usd_fin}=$hash{USD};
		$first->{unformat_eur_fin}=$hash{EUR};
		
	}
	

	my $tmpl;
	###for working ony with USD,EUR or only UAH
    my $run_mode=$self->get_current_runmode();
    ###
    if($run_mode eq 'list'){

         $run_mode='list';
    }else{

        $run_mode='print';

    }

	unless($resident){
		$tmpl=$self->load_tmpl("dayfirm_$run_mode.html");

	}else{
		$tmpl=$self->load_tmpl("dayfirm_$run_mode"."_uah.html");
	}
   	
	$self->{tpl_vars}->{list}=\@res;
	$self->{tpl_vars}->{resident}=$resident;
	
	$self->restore_date($date);
	
	my $output = "";
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;

}

sub find_first_input
{
	my ($ref,$id)=@_;
	my $i=0;
	map{return $i-1 if(++$i&&$_->[6]==$id) } @$ref;
	return  -1;
}
		
sub restore_date
{
	my ($self,$date)=@_;
	my ($current_year,$current_mon,$current_day)=split('-',$date);
 	$self->{tpl_vars}->{selected}->{month}=$current_mon;
	$self->{tpl_vars}->{selected}->{day}=$current_day;
	$self->{tpl_vars}->{selected}->{year}=$current_year;

}
1;

	

