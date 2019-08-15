#!/usr/bin/perl
use strict;
open(FL,">>/tmp/test");
system('/usr/local/bin/mysql -ufsb_user -hlocalhost  -prandomnumber fsb -e "UPDATE cashier_transactions SET ct_date=NOW() WHERE
ct_fid>0 AND ct_date<NOW() AND ct_req=\'yes\' "') or print FL $!;
system('/usr/local/bin/mysql -ufsb_user -hlocalhost -prandomnumber fsb -e "optimize table cashier_transactions"');
system('/usr/local/bin/mysql -ufsb_user -hlocalhost -prandomnumber fsb -e "optimize table transactions"'); 
system('/usr/local/bin/mysql -ufsb_user -hlocalhost -prandomnumber fsb -e "optimize table accounts_reports_table"');  
system('/usr/local/bin/mysql -ufsb_user -hlocalhost -prandomnumber fsb -e "optimize table accounts_reports_table_archive"');  
#system('/usr/local/bin/mysql -ufsb_user -hlocalhost -prandomnumber fsb -e "optimize table accounts_reports_table_union"');  


print FL "wokr ";
close(FL);
