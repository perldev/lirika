#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../firm_lib';

use Oper::FirmInput;
Oper::FirmInput->new->run;

exit(0);
