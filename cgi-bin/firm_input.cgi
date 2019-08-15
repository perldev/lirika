#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::FirmInput;
Oper::FirmInput->new->run;

exit(0);
