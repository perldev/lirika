#/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
#use lib '../lib';

#use Oper::CashierInput;
my $d=Oper::CashierInput->new();
$d->{cash}='kiev2';
$d->run();

exit(0);
