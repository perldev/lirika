#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../firm_lib';
use Oper::FirmDocs;
Oper::FirmDocs->new->run;

exit(0);
