#!/usr/bin/perl
use strict;
use lib qw(../lib);
use CGI::Carp qw(fatalsToBrowser);
use Oper::UI;
my $r=Oper::UI->new();
$r->run();