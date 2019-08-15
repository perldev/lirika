#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::CashierOutput2;
my $r=Oper::CashierOutput2->new();
$r->{cash}='dnepr';
$r->run;

exit(0);
