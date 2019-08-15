#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::Operators;
Oper::Operators->new->run;

exit(0);
