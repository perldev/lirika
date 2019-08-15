#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../firm_lib';
use Oper::Ajax;
Oper::Ajax->new->run;

exit(0);
