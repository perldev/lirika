#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::ExchangeOdessa;
$r = Oper::ExchangeOdessa->new();
$r->run();

#exit(0);
