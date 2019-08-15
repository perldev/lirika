#!/usr/bin/perl 
use strict;
use lib q(/usr/local/www/lib);
###this script show you how lazy i am
open(F,">>/tmp/test");
system('/usr/local/bin/mysql -ufsb_user -hlocalhost  -prandomnumber fsb -e "UPDATE cashier_transactions SET ct_date=NOW() WHERE
ct_fid>0 AND ct_date<NOW() AND ct_req=\'yes\' "') or print F $!;
chroot('/usr/local/www/cron');
use Oper::AccountsReports;
my $webapp = Oper::AccountsReports->new();
use SiteDB;
my $ref=$dbh->selectall_arrayref(q[SELECT a_id FROM accounts WHERE  a_issubs='yes']);
foreach(@$ref)
{
	$webapp->{non_login}=1;
	$webapp->query->param('do','send_balance');
	$webapp->query->param('ct_aid',$_->[0]);
	$webapp->query->param('action','filter');
	print F $webapp->run();
}




print F "wokr \n";
close(F);
