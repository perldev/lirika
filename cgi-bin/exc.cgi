#!/usr/bin/perl
use strict;
use lib qw(../lib);
use CGI::Carp qw(fatalsToBrowser);

use Oper::Exchange;
my $r=Oper::Exchange->new();
$r->run();
