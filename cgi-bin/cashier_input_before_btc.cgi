#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::CashierInputBefore;
my $r=Oper::CashierInputBefore->new();
$r->{currencies} = [{'value'=>"BTC", 'title'=>"BTC"}];
$r->{cash}='btc';

$r->run();

exit(0);
