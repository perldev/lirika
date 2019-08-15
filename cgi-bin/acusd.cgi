#/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
#use lib '../lib';
#use Oper::AccountsReportsUSD;
Oper::AccountsReportsUSD->new->run;

exit(0);
