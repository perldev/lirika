#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';
use Oper::Ajax;
Oper::Ajax->new->run;

exit(0);
