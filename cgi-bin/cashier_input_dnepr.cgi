#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::CashierInput;
my $r=Oper::CashierInput->new();
$r->{cash}='kiev1';
$r->run;
exit(0);
