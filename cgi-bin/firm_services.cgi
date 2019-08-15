#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::FirmServices;
Oper::FirmServices->new->run;

exit(0);
