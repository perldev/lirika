#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::Credits_Objections;
Oper::Credits_Objections->new->run;

exit(0);
