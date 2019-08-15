#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../firm_lib';
use Oper::Notes;
Oper::Notes->new->run;
exit(0);
