#/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
#use lib '../lib';

#use Oper::FirmTransUSD;
Oper::FirmTransUSD->new->run;

exit(0);
