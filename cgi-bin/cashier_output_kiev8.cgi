#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::CashierOutput;
my $r=Oper::CashierOutput->new();
$r->{cash}='kiev8';
$r->run();

exit(0);
