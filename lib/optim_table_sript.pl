#!/usr/bin/perl
use strict;
open(FL,">>/tmp/test");
my $MYSQL='/usr/bin/mysql';

system(qq[$MYSQL -ufsb_user -hlocalhost  -prandomnumber fsb -e "UPDATE cashier_transactions 
	SET ct_date=NOW() WHERE
	ct_fid>0 AND ct_date<DATE(NOW())
	AND ct_req=\'yes\' AND ct_status!=\'deleted\' " ]) or print FL $!;
system(qq[$MYSQL -ufsb_user -hlocalhost -prandomnumber fsb -e "optimize table cashier_transactions"])  or print FL $!;
system(qq[$MYSQL -ufsb_user -hlocalhost -prandomnumber fsb -e "optimize table transactions"])  or print FL $!; 
system(qq[$MYSQL -ufsb_user -hlocalhost -prandomnumber fsb -e "optimize table accounts_reports_table"])  or print FL $!;  
system(qq[$MYSQL -ufsb_user  -hlocalhost -prandomnumber fsb -e "optimize table accounts_reports_table_archive"])  or print FL $!;  
#system('/usr/local/bin/mysql -ufsb_user -hlocalhost -prandomnumber fsb -e "optimize table accounts_reports_table_union"');  
my $now_string = localtime;

print FL "work  $now_string \n";
close(FL);
