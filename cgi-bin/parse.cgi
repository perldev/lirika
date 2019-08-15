#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';
use strict;
use MIME::Parser;
use SiteDB;
use Data::Dumper;
use SiteConfig;
use SiteCommon;
database_connect();
use Template;
use Encode;
use CGI qw(:standard);
use locale;
use POSIX 'locale_h';

setlocale(&POSIX::LC_CTYPE,"ru_RU.cp1251");

print header(-type=>'text/html',
             -charset=>'cp1251');
$ENV{LC_ALL} = 'ru_RU.cp1251';
die(lc 'ÒÅÑÒ');
my $sth=$dbh->prepare(q[SELECT 
                        rm_id
                        FROM 
                        reports_mail 
                       WHERE rm_status='new' 
                       ]);

$sth->execute();
while(my $row=$sth->fetchrow_hashref())
{
	#$dbh->do(q[update reports_mail set rm_status='processed' where rm_id=?],undef,$row->{rm_id});
    my $parser = new MIME::Parser;
    $parser->output_under($MAIL_DIR);
    my $entity = $parser->parse_open($MAIL_DIR.'/msg'.$row->{rm_id}) or die "parse failed\n";
    #die($entity->{ME_Parts}->[0]->{mail_inet_head}->{mail_hdr_list}->[0]);
   	foreach my $r(@{$entity->{ME_Parts}})
   	{
   		#die(Dumper($r));
	    if(index($r->{mail_inet_head}->{mail_hdr_list}->[0],'text/plain')==-1)
	    {
	   		do_main($r->{ME_Bodyhandle}->{MB_Path},$row->{rm_id});
	    }
	}
	#$dbh->do(q[update reports_mail set rm_status='parsed' where rm_id=?],undef,$row->{rm_id});

}


#######################################################################
## Parse excel
#######################################################################



use Spreadsheet::ParseExcel;


sub do_main
{
  my $path_to_excel_file  = shift;
  my $id_mail =shift;
  my ($oBook, $iR, $iC, $oWkS, $oWkC);
  my ($date1, $date2,$date3);
  my $flag =1;
  $oBook = Spreadsheet::ParseExcel::Workbook->Parse($path_to_excel_file);
  my $accounts = get_accounts_name_id();
  foreach my $oWkS (@{$oBook->{Worksheet}})
  {
  	if($flag)
  	{
  		my $tmp = $oWkS->{MinRow};
  		$date1 = $oWkS->{Cells}[$tmp][4]->{_Value};
  		if ($date1 =~ /([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{2,4})/)
  		{
  			$date1 = $3.'-'.$2.'-'.$1;
  		}
  		else
  		{
  			return;
  		}
		$date2 = $oWkS->{Cells}[$tmp][6]->{_Value};
  		if ($date2 =~ /([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{2,4})/)
  		{
  			$date2 = $3.'-'.$2.'-'.$1;
  		}
  		else
  		{
  			return;
  		}
  		$date3 = $oWkS->{Cells}[$tmp][9]->{_Value};
  		if ($date3 =~ /([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{2,4})/)
  		{
  			$date3 = $3.'-'.$2.'-'.$1;
  		}
  		else
  		{
  			return;
  		}
		$flag = 0;
  	}
  	my $flag_exit =0;
    for (my $iR = $oWkS->{MinRow}+1; defined $oWkS->{MaxRow} && $iR <= $oWkS->{MaxRow} ; $iR++)
    {
  		my $excel_row = {};
    	$excel_row->{firm} = encode("cp1251", $oWkS->{Cells}[$iR][0]->{_Value});
		$flag_exit++ if($excel_row->{firm} eq '');
		last if($flag_exit>2);
		$excel_row->{out_firm} = encode("cp1251", $oWkS->{Cells}[$iR][2]->{_Value});
		$excel_row->{okpo} = encode("cp1251", $oWkS->{Cells}[$iR][1]->{_Value});
		$excel_row->{account} = encode("cp1251", $oWkS->{Cells}[$iR][3]->{_Value});
		last if($excel_row->{firm} eq 'ÈÒÎÃÎ' || $excel_row->{out_firm} eq 'ÈÒÎÃÎ' || $excel_row->{okpo} eq 'ÈÒÎÃÎ' || $excel_row->{firm} eq 'Ğàçîì' || $excel_row->{out_firm} eq 'Ğàçîì' || $excel_row->{okpo} eq 'Ğàçîì');

		$excel_row->{sum1} = encode("cp1251",$oWkS->{Cells}[$iR][4]->{_Value});
		$excel_row->{sum2} = encode("cp1251",$oWkS->{Cells}[$iR][5]->{_Value});
		$excel_row->{sum3} = encode("cp1251",$oWkS->{Cells}[$iR][6]->{_Value});
		$excel_row->{pay_form} = encode("cp1251", $oWkS->{Cells}[$iR][7]->{_Value});
		$excel_row->{sum4} = encode("cp1251",$oWkS->{Cells}[$iR][8]->{_Value});
		$excel_row->{sum5} = encode("cp1251",$oWkS->{Cells}[$iR][9]->{_Value});
		$excel_row->{sum6} = encode("cp1251",$oWkS->{Cells}[$iR][10]->{_Value});
		$excel_row->{account_id} = 0;
		
		if($accounts->{$excel_row->{account}})
		{
			$excel_row->{account_id} = $accounts->{$excel_row->{account}};
		}
		else
		{
			$excel_row->{account_id} = searchId($accounts,$excel_row->{account});
		}
    	if(($excel_row->{sum6}*1 || $excel_row->{sum5}*1 || $excel_row->{sum4}*1 || $excel_row->{sum4}*1 || $excel_row->{sum2}*1 || $excel_row->{sum1}*1) && ($excel_row->{firm} ne "" || $excel_row->{okpo} ne ""))
    	{
    		$dbh->do(q[INSERT INTO `fsb`.`reports_in_mail` (`rm_id`,`rm_date1` ,`rm_date2` ,`rm_date3`,`rm_id_mail`,`rm_firm`,`rm_out_firm`,
		  	`rm_okpo` ,`rm_accounts`,`rm_sum1`,`rm_sum2`,`rm_sum3`,`rm_sum4`,`rm_sum5`,`rm_sum6`,`rm_pay_form`,`rm_accounts_id`,`rm_date_add`)
			VALUES (NULL ,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,CURDATE())],
			undef,
			$date1,$date2,$date3,$id_mail,$excel_row->{firm},$excel_row->{out_firm},
			$excel_row->{okpo},$excel_row->{account},$excel_row->{sum1},$excel_row->{sum2},$excel_row->{sum3},$excel_row->{sum4},$excel_row->{sum5},$excel_row->{sum6},$excel_row->{pay_form},$excel_row->{account_id});
        }
        
    }
  }
}
sub get_accounts_name_id
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
		$firms->{$row->{a_name}} = $row->{a_id};
	}
	return $firms;
}

sub searchId
{
	my $accounts = shift;
	my $searched_string = shift;
	my $min = length($searched_string);
	my $id = 0;
	my $lev =0;
	foreach my $r(keys(%$accounts))
	{
		$lev = levenshtein($searched_string,$r);
		#die($lev) if($r eq 'ëèôø' && $searched_string eq 'ëèôøèö');
		
		if($lev<=$min)
		{
			$id = $accounts->{$r};
			$min = $lev;
		} 
		last if($min<2);
	}
	return $id if($min<=3);
	return 0;
}

sub levenshtein($$){
  my $str1 =  lc shift;
  my $str2 =  lc shift;
  
  die $str1.' - '.$str2."<br/>";
  my @A=split //, $str1;
  my @B=split //, $str2;
  my @W=(0..@B);
  my ($i, $j, $cur, $next);
  for $i (0..$#A){
        $cur=$i+1;
        for $j (0..$#B){
                $next=min(
                        $W[$j+1]+1,
                        $cur+1,
                        ($A[$i] ne $B[$j])+$W[$j]
                );
                $W[$j]=$cur;
                $cur=$next;
        }
        $W[@B]=$next;
  }
  return $next;
}
 
sub min($$$){
  if ($_[0] < $_[2]){ pop; } else { shift; }
  return $_[0] < $_[1]? $_[0]:$_[1];
}
