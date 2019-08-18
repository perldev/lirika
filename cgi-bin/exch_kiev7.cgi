#/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
#use lib '../lib';

#use Oper::ExchangeKiev;
Oper::ExchangeKiev->new();
$r->{cash}='kiev7';
$r->run;
exit(0);













