#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::DayFirm;
Oper::DayFirm->new->run;

exit(0);
