#/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
#use lib '../lib';

#use Oper::CashierInputBefore;
my $r=Oper::CashierInputBefore->new();
$r->{cash}='kiev';
$r->run();

exit(0);
