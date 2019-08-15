#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../firm_lib';

use Oper::FirmTrans;
Oper::FirmTrans->new->run;

exit(0);
