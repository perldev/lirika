#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::Correctings;
Oper::Correctings->new->run;

exit(0);
