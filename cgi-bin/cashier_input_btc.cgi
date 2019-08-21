#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::CashierInput;
my $d=Oper::CashierInput->new();
$d->{cash}='btc';
$r->{currencies} = [{'value'=>"BTC", 'title'=>"BTC"}];
$d->run();

exit(0);
