#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';
use Oper::Transfers;
Oper::Transfers->new->run;
exit(0);
