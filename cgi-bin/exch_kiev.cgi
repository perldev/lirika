#/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
#use lib '../lib';

#use Oper::ExchangeKiev;
Oper::ExchangeKiev->new->run;

exit(0);













