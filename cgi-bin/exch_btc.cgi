#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::ExchangeKiev;
my $r = Oper::ExchangeKiev->new();
$r->{cash}='kiev8';
$r->run;
exit(0);












