#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';
use Oper::Transit;
Oper::Transit->new->run;

exit(0);
