#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../firm_lib';
use Oper::FirmOut;
Oper::FirmOut->new->run;

exit(0);
