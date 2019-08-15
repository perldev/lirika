#/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
#use lib '../lib';
#use Oper::CashierInputOne;

my $d=Oper::CashierInputOne->new();

$d->{cash}='kiev';

$d->run();

exit(0);
