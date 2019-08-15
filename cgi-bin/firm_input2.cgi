#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::FirmInput2;
Oper::FirmInput2->new->run;

exit(0);
