#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
#use Data::Dumper;
#die Dumper \%ENV;

use lib '../firm_lib';
use Oper::Index;
Oper::Index->new->run;

exit(0);
