#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';
use Oper::FactDocs;
Oper::FactDocs->new->run;

exit(0);
