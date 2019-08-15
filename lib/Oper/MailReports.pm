package Oper::MailReports;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
use Documents;
use Encode;
use locale;
my $proto;

sub get_right{       
     my $self=shift;
   


 $proto={
    'table'=>"reports_mail",  
    'template_prefix'=>"reports_mail",
    'need_confirmation'=>0,
    'page_title'=>"Îò÷åòû",
    'sort'=>'rm_date3 ASC',
    #'key_hashes'=>['key_field','dr_fid','dr_aid','dr_id'],
    'fields'=>[
    {
    'field'=>"rm_accounts_id", "title"=>"Ïğîãğàììà", "category"=>"accounts",
	    'type'=>'select',
    
	    'filter'=>'=',select_search=>1
        },
        {'field'=>"rm_date2", "title"=>"Äàòà",  'category'=>"date",'filter'=>"date_month_year"},
    ]
    };	
    #$proto->{fields}->[2]->{titles}=&get_out_firms_okpo();
    #$proto->{fields}->[3]->{titles}=&get_out_firms();
    $proto->{fields}->[0]->{titles}=&get_accounts_simple(2);


    return 'saldo_documents';
}
sub setup{
  my $self = shift;
  $self->start_mode('list');
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'built_excel'=>'built_excel'
  );
}
sub list{
	my $self = shift;
    
    $self->{tpl_vars}->{accounts}=&get_accounts_simple(2);
    use Data::Dumper;
	#die(Dumper($self->query->param('rm_date_add_to')));
	$proto->{table}='reports_in_mail';
 	#$proto->{group}='group by `dr_fid`,`dr_aid`,`dr_currency`,`dr_ofid_from`,`dr_status`,dr_date';
	return $self->proto_list($proto,{fetch_row=>\&date});
	#my $params=$self->get_documents_list($proto);
	
	#die($TIMER->stop);
	
	#set_calc_persent_comissions($params);
	#$params->{file}='mail_reports_list.html';
	#return $self->template_proto_list($params);
	
}
sub date
{
	##$prev_row - in our case its date
	my ($array,$row,$prev_row,$proto)=@_;
	my $flag=0;
	my $r;	
	my $tmp = @$array-1;

	unless($array->[0])
	{
		$r = {rm_sum1=>format_date($row->{rm_date1}),
		rm_sum3=>format_date($row->{orig__rm_date2}),
		rm_sum5=>format_date($row->{rm_date3}),
		sys_row=>'yes',
		m1=>$row->{rm_date1},
		m2=>$row->{rm_date3},
		};
		format_datetime_month_year(\$r->{m1});
		format_datetime_month_year(\$r->{m2});
		$flag = 1
	}
	elsif(format_date($row->{rm_date1}) ne $array->[$tmp]->{rm_date1} || format_date($row->{orig__rm_date2}) ne $array->[$tmp]->{rm_date2})
	{
		#die(Dumper($row->{rm_date1}).'<br/>'.Dumper($array->[$tmp]) );
		$r = {rm_sum1=>format_date($row->{rm_date1}),
		rm_sum3=>format_date($row->{orig__rm_date2}),
		rm_sum5=>format_date($row->{rm_date3}),
		sys_row=>'yes',
		m1=>$row->{rm_date1},
		m2=>$row->{rm_date3},
		};
		format_datetime_month_year(\$r->{m1});
		format_datetime_month_year(\$r->{m2});
		$flag = 1
	}
#		$row->{currency1}=$row->{e_currency2};
		push @$array,$r if($flag);
		push @$array,$row;
}

sub built_excel
{
	use Data::Dumper;
	my ($self)=shift;
	my $accounts = get_accounts_id_name();
	my $mounth = $self->query->param('mounth');
	my $year = $self->query->param('year');
	my $aid = $self->query->param('rm_aid');
	my $from = "$year-$mounth-01";
	my $to = "$year-$mounth-31";
    my $file_server=int(rand(1000));
    my $file2="excel/$file_server.xls";
    my $file = "$EXCEL_EXPORT_PATH$file_server.xls";
    unlink("$EXCEL_EXPORT_PATH$file_server.xls");
	
	require Spreadsheet::WriteExcel::Simple;
	my $ss = Spreadsheet::WriteExcel::Simple->new;
	my $sth;
	if($aid)
	{
		$sth=$dbh->prepare(q[SELECT 
                        *
                        FROM 
                        reports_in_mail 
                       WHERE rm_date2>=? and rm_date2<=? and rm_accounts_id=?
                       order by rm_date3
                       ]);

		$sth->execute($from,$to,$aid);
	}
	else
	{
		$sth=$dbh->prepare(q[SELECT 
                        *
                        FROM 
                        reports_in_mail 
                       WHERE rm_date2>=? and rm_date2<=?
                       order by rm_date3
                       ]);

		$sth->execute($from,$to);
	}
	my $date3;
	my @sums=[0,0,0,0,0,0];
	my $flag =0;
	
	while(my $row=$sth->fetchrow_hashref())
	{
		
		if($date3 ne $row->{rm_date3})
		{
			if($flag)
			{
				
				my @cal_row=('Èòîãî','','','',"$sums[1]","$sums[2]","$sums[3]",'',"$sums[4]","$sums[5]","$sums[6]");
				#die(Dumper($mounth));
				map {	$_=my_decode($_) } @cal_row;
				$ss->write_bold_row(\@cal_row);
				$ss->write_row(['']);
				@sums=[0,0,0,0,0,0];
			}
			
			my $my1 = $row->{rm_date1};
			format_datetime_month_year(\$my1);
			my $my2 = $row->{rm_date3};
			format_datetime_month_year(\$my2);
			my $d1=format_date($row->{rm_date1});
			my $d2=format_date($row->{rm_date2});
			my $d3=format_date($row->{rm_date3});
			#die(format_datetime_month_year(\$row->{rm_date1}));
			my @headings=('Ôèğìà','Íàèìåíîâàíèå ïğåäïğèÿòèÿ','Êîä ÎÊÏÎ','Êëèåíò',"Ñàëüäî íà $d1",'Îáîğîò ïî äîêóìåíòàì çà '.$my1,"Ñàëüäî íà $d2",'Ôîğìà îïëàòû','Ñóììà îïëàòû '.$my1,"Ñàëüäî íà $d3",'Ñóììà îïëàòû '.$my2);
			#die(Dumper($mounth));
			map {	$_=my_decode($_) } @headings;
			$ss->write_bold_row(\@headings);
			$date3 = $row->{rm_date3};
			$flag =1;
		}
		
		foreach my $r(keys(%{$row}))
		{
			$row->{$r} = my_decode($row->{$r});
		}
		$row->{rm_accounts} = $accounts->{$row->{account_id}} if($row->{account_id});
		
		$ss->write_row([$row->{rm_firm},$row->{rm_out_firm},$row->{rm_okpo},$row->{rm_accounts},$row->{rm_sum1},
		$row->{rm_sum2},$row->{rm_sum3},$row->{rm_pay_form},$row->{rm_sum4},$row->{rm_sum5},$row->{rm_sum6}]);
		$sums[1] += $row->{rm_sum1};
		$sums[2] += $row->{rm_sum2};
		$sums[3] += $row->{rm_sum3};
		$sums[4] += $row->{rm_sum4};
		$sums[5] += $row->{rm_sum5};
		
		$sums[6] += $row->{rm_sum6};
	}
	my @cal_row=('Èòîãî','','','',"$sums[1]","$sums[2]","$sums[3]",'',"$sums[4]","$sums[5]","$sums[6]");
	#die(Dumper($mounth));
	map {	$_=my_decode($_) } @cal_row;
	$ss->write_bold_row(\@cal_row);
	$ss->write_row(['']);
	@sums=[0,0,0,0,0,0];
	
    $ss->save($file) or die $!;
    return $file2;
}

sub get_accounts_id_name
{
	my $firms ={};
	my $sth=$dbh->prepare(q[SELECT 
                        a_name,a_id
                        FROM 
                        accounts 
                        where a_status='active'
                      ]);

	$sth->execute();

	while(my $row=$sth->fetchrow_hashref())
	{
		$firms->{$row->{a_id}} = $row->{a_name};
	}
	return $firms;
}



1;
