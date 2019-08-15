#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::CashierInputOne;
my $r=Oper::CashierInputOne->new();

$r->{cash}='dnepr';
$r->run;

exit(0);
