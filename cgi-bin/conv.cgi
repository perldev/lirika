#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';

use Oper::FirmsConv;
Oper::FirmsConv->new->run;

exit(0);
