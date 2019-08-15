#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';
use Oper::ReqFirms;
Oper::ReqFirms->new->run;

exit(0);
