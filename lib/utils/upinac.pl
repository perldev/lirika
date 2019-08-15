#!/usr/bin/perl
use strict;
use Data::Dumper;
use MyConfig;
use lib $MyConfig::path;
use SiteDB;

database_connect();

my $r=$dbh->selectall_arrayref(q[SELECT a_id,
 REPLACE( REPLACE( REPLACE(a_name,".",""),"-","")," ",'')  FROM accounts  WHERE a_status='active' 
ORDER BY a_name]);
open(FL,"debts.txt") or die $!;
my @a=<FL>;
close(FL);
my $size=@a;
my (@well,@bad,%well);
foreach(@a){
    
    my @aa=split(/,/,$_);
    my $str=$aa[1];
    $str=~s/[\.\-\n ]//g;
    my $aid=$dbh->selectrow_array(qq[SELECT a_id FROM accounts WHERE 
lcase( REPLACE( REPLACE( REPLACE(a_name,".",""),"-","")," ",'') ) = lcase(REPLACE( REPLACE( REPLACE('$str',".",""),"-","")," ",'') )  AND a_status='active']);	

   if($aid){
        push @well,{amnt=>$aa[0],a_id=>$aid};
    }else{
        push @bad,$str;
    }

}

=pod
+-----------+--------------+------+-----+---------+-------+
| Field     | Type         | Null | Key | Default | Extra |
+-----------+--------------+------+-----+---------+-------+
| kand_aid  | int(11)      | NO   |     | NULL    |       | 
| kand_debt | double(12,4) | YES  |     | NULL    |       | 
+-----------+--------------+------+-----+---------+-------+
=cut

my $sql='INSERT kostial_accounts_new_docs(kand_aid,kand_debt) VALUES';
foreach(@well){
    $sql.="($_->{a_id},$_->{amnt}),";
}
chop($sql);

print "normal $sql \n";

print " erro - \n";
foreach(@bad){
    print "$_ \n";
}









