#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::CashierOutput;
my $r=Oper::CashierOutput->new();
$r->{cash}='btc';
$r->{currencies} = [{'value'=>"BTC", 'title'=>"BTC"}];
$r->run();

exit(0);
