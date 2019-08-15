#!/usr/bin/perl
use Data::Dumper;
use DBI;
my $dsn = "DBI:mysql:host=localhost;database=fsb";
$dbh=DBI->connect($dsn,'root','ada', { RaiseError => 1});
$dbh->do("SET charset cp1251;");
$dbh->do("SET names   cp1251;");

$dbh->do(q[UPDATE exchange_view SET e_type='auto' WHERE  t_comment like 'Автообмен%']);
$dbh->do(q[UPDATE exchange_view SET e_type='cashless' WHERE  t_comment NOT  like 'Автообмен%' AND e_type='auto']);

$dbh->do(q[UPDATE transactions SET t_status='system' 
		WHERE 
		t_comment not like '%Отмена%'  AND t_comment not like '%Откат%' AND t_comment not like 'Автообмен%' AND  
		t_comment  not like 'Дополнительная%' 
		AND
		t_comment not like 'Комисс%' 
		AND 
		t_comment not like 'Вывод%' 
		AND t_comment not like 'Ввод%' 
		AND   t_aid1 NOT IN (-5,-4,-2,-1) AND t_aid2 NOT IN (-5,-4,-2,-1) AND 1  ]);


$dbh->disconnect();

die("here");

open(FL,"firm_balances.txt") or die $!;
my @arr;
my @res;
my $id;
my $flg=0;
print "currency_fimrs: \n";
while(<FL>)
{
	my @a=split(/\t/,$_);

		
	#print " 1:$a[0] 2:$a[1] 3:$a[2] 4:$a[3] \n
	if($_=~/UAH/)
	{
		$flg=1;
		print " native firms \n";
	}
	if(!$a[1]||$a[1] eq '')
	{
		next;
	}

	unless($flg)
	{
		
		$a[2]=0	unless($a[2]);	
		$a[3]=0	unless($a[3]);
	
		
		my $id=$dbh->do(q[update  firms SET f_usd=?,f_eur=? WHERE lcase(f_name)=lcase(?) ],
		undef,1*$a[2],1*$a[3],$a[1]);
		print "something wrong with $a[1]" if($id ne '1');
	}else
	{
		
	
		my $id=$dbh->do(q[UPDATE   firms SET f_uah=? WHERE lcase(f_name)=lcase(?)],undef,1*$a[2],$a[1]);
		print "something wrong with $a[1] \n"    if($id ne '1');
		
	}

}
close(FL);
my @curs=('UAH','USD','EUR');
my $cur;
foreach(@curs)
{
    my $ref=$dbh->selectall_arrayref(q[select  f_id,sum(ct_amnt),
    ct_date from cashier_transactions,firms 
    WHERE  (day(ct_date)>20 OR (day(ct_date)<=20 AND ct_oid not in (6,2) )) and ct_currency=?  and ct_fid=f_id GROUP BY f_id;
    ],undef,$_); 
    
    $cur=lc($_);
    
        
    
    foreach my $k(@$ref)
    {
	if(1*$k->[1]>0)
	{
	    print "$k->[0] $k->[1] \n";
    	    $dbh->do(qq[UPDATE firms set f_$cur=f_$cur+? WHERE f_id=? ],undef,$k->[1],$k->[0]);
	
	}else
	{
	    print "$k->[0] $k->[1] \n";
	    $dbh->do(qq[UPDATE firms set f_$cur=f_$cur+? WHERE f_id=? ],undef,$k->[1],$k->[0]);
	}
    
    }


}

# 
# print "The list of  new accounts , which  have been added \n";
# map {print $_."\n" } @arr;
# 
# my $str=join(',',@res);
# my $ref=$dbh->selectall_arrayref(qq[SELECT a_name FROM accounts WHERE a_id NOT IN ($str) AND a_id>1]);
# print "The list of deleted accounts \n";
# 	foreach(@$ref)
# 	{
# 		print 	"$_->[0] \n";
# 
# 	}


$dbh->disconnect;
