#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::Banks;
Oper::Banks->new->run;

exit(0);
