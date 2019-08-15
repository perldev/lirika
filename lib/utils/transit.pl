#!/usr/bin/perl
use MyConfig;
use lib $MyConfig::path;
use SiteDB;
database_connect();
my $aid=shift;

my $ref=$dbh->selectall_arrayref(q[SELECT ct_id, ct_amnt, abs(ct_amnt), ct_comment, col_status FROM accounts_reports_table WHERE ct_aid=?],undef,$aid);
my %work=();
my @in=();
my $i=0;
foreach my $tmp (@$ref){
	
	my $r=$work{ -1*$tmp->[1] };
	if($r){
		my $size1=@{ $r->{yes} };
		my $size2=@{ $r->{no} };	
		if(($size1+$size2)>1){
			pop @{ $r->{ $tmp->[4] } };

		}else{
			delete $work{ -1*$tmp->[1] };
		
		}
		next;
	}
	
	unless($work{ $tmp->[1] }){
		
		$work{ $tmp->[1] }->{yes}=[];
		$work{ $tmp->[1] }->{no}=[];

		push @{ $work{ $tmp->[1] }->{ $tmp->[4] } } ,$tmp->[0];

	}else{
		push @{ $work{ $tmp->[1] }->{ $tmp->[4] } } ,$tmp->[0];

	}
	
	
	
	
	
=pod

	$i++;

	unless($work{$tmp->[0]}){
		$work{$tmp->[0]}=$tmp->[1];
	}else{
		next;
	}
	my $find=0;	
	foreach my $t (@$ref){
		
		next if($tmp->[0]==$t->[0]);
		if(!$work{$t->[0]}&&(-1*$t->[1])==$tmp->[1]){
			$work{$t->[0]}=$t->[1];
			$find=1;
			last ;

		}		
			
				
	}

	push @in,$tmp	unless($find);
=cut

}

#my $size=@in;
print "  \n";
my $sum=0;
foreach(@in){
	$sum+=$_->[0];
	print "$_->[0] , $_->[1] ,$_->[2] \n";
}
print "delta $sum \n";

exit(0);












