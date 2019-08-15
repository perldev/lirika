#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../firm_lib';
use Oper::Docs;
Oper::Docs->new->run;
exit(0);
