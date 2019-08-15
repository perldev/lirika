#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../firm_lib';

use Oper::Firms;
Oper::Firms->new->run;

exit(0);
