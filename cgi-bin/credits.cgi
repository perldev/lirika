#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::Credits;
Oper::Credits->new->run;

exit(0);
