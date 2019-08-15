#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::FirmOutput;
Oper::FirmOutput->new->run;

exit(0);
