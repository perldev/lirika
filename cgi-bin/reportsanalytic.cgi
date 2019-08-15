#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::ReportsAnalytic;
Oper::ReportsAnalytic->new->run;

exit(0);
